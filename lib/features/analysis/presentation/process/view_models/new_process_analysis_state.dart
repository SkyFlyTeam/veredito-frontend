import 'dart:io';

import '../../../domain/entities/processo_juridico.dart';
import '../../../domain/entities/tribunal_precedente.dart';

class NewProcessAnalysisState {
  final bool isLoadingTribunais;
  final bool isSubmitting;
  final List<TribunalPrecedente> tribunais;
  final TribunalPrecedente? selectedTribunal;
  final int? instancia;
  final String areaDireito;
  final String classeProcessual;
  final File? file;
  final String? errorMessage;
  final bool showValidationErrors;
  final ProcessoJuridico? createdProcesso;

  const NewProcessAnalysisState({
    this.isLoadingTribunais = false,
    this.isSubmitting = false,
    this.tribunais = const [],
    this.selectedTribunal,
    this.instancia,
    this.areaDireito = '',
    this.classeProcessual = '',
    this.file,
    this.errorMessage,
    this.showValidationErrors = false,
    this.createdProcesso,
  });

  NewProcessAnalysisState copyWith({
    bool? isLoadingTribunais,
    bool? isSubmitting,
    List<TribunalPrecedente>? tribunais,
    TribunalPrecedente? selectedTribunal,
    int? instancia,
    String? areaDireito,
    String? classeProcessual,
    File? file,
    String? errorMessage,
    bool? showValidationErrors,
    ProcessoJuridico? createdProcesso,
    bool clearError = false,
  }) {
    return NewProcessAnalysisState(
      isLoadingTribunais: isLoadingTribunais ?? this.isLoadingTribunais,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      tribunais: tribunais ?? this.tribunais,
      selectedTribunal: selectedTribunal ?? this.selectedTribunal,
      instancia: instancia ?? this.instancia,
      areaDireito: areaDireito ?? this.areaDireito,
      classeProcessual: classeProcessual ?? this.classeProcessual,
      file: file ?? this.file,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      showValidationErrors:
          showValidationErrors ?? this.showValidationErrors,
      createdProcesso: createdProcesso ?? this.createdProcesso,
    );
  }
}
