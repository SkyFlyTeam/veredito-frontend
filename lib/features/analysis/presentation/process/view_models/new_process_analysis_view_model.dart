import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/tribunal_precedente.dart';
import '../../../domain/use_cases/filters_use_case.dart';
import '../../../domain/use_cases/process_use_case.dart';
import 'new_process_analysis_state.dart';

class NewProcessAnalysisViewModel
    extends StateNotifier<NewProcessAnalysisState> {
  final FiltersUseCase _filtersUseCase;
  final ProcessUseCase _processUseCase;
  bool _didLoad = false;

  NewProcessAnalysisViewModel(this._filtersUseCase, this._processUseCase)
      : super(const NewProcessAnalysisState());

  Future<void> initialize() async {
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    await _loadTribunais();
  }

  Future<void> retryTribunais() async {
    await _loadTribunais();
  }

  void setAreaDireito(String value) {
    state = state.copyWith(areaDireito: value, clearError: true);
  }

  void setClasseProcessual(String value) {
    state = state.copyWith(classeProcessual: value, clearError: true);
  }

  void setInstancia(int? value) {
    state = state.copyWith(instancia: value, clearError: true);
  }

  void setTribunal(TribunalPrecedente? tribunal) {
    state = state.copyWith(selectedTribunal: tribunal, clearError: true);
  }

  void setFile(File? file) {
    state = state.copyWith(file: file, clearError: true);
  }

  void setErrorMessage(String message) {
    state = state.copyWith(errorMessage: message);
  }

  Future<void> submit() async {
    final file = state.file;
    final areaDireito = state.areaDireito.trim();
    final classeProcessual = state.classeProcessual.trim();
    final tribunal = state.selectedTribunal;
    final instancia = state.instancia;

    final hasValidationError =
        file == null ||
        areaDireito.isEmpty ||
        classeProcessual.isEmpty ||
        tribunal == null ||
        instancia == null;

    if (hasValidationError) {
      state = state.copyWith(
        errorMessage: 'Preencha todos os campos.',
        showValidationErrors: true,
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      showValidationErrors: false,
    );

    try {
      final processo = await _processUseCase.createProcessoJuridico(
        file,
        areaDireito,
        classeProcessual,
        tribunal,
        instancia,
      );

      state = state.copyWith(
        isSubmitting: false,
        createdProcesso: processo,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Nao foi possivel criar o processo juridico.',
      );
    }
  }

  Future<void> _loadTribunais() async {
    state = state.copyWith(isLoadingTribunais: true, clearError: true);

    try {
      final tribunais = await _filtersUseCase.getTribunais();
      state = state.copyWith(isLoadingTribunais: false, tribunais: tribunais);
    } catch (_) {
      state = state.copyWith(
        isLoadingTribunais: false,
        errorMessage: 'Nao foi possivel carregar os tribunais.',
      );
    }
  }
}
