import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../analysis/domain/entities/secao_peticao.dart';
import '../../../../analysis/domain/use_cases/caso_juridico_use_case.dart';
import 'minuta_peticao_state.dart';

class MinutaPeticaoViewModel extends StateNotifier<MinutaPeticaoState> {
  final CasoJuridicoUseCase _useCase;

  MinutaPeticaoViewModel(this._useCase, MinutaPeticaoState initialState)
      : super(initialState);

  /// Carrega as seções da petição via backend
  Future<void> initialize() async {
    final casoId = state.peticao.id;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      debugPrint('MinutaPeticaoViewModel: gerando petição para casoId=$casoId');
      final secoes = await _useCase.gerarPeticao(casoId);
      debugPrint(
        'MinutaPeticaoViewModel: ${secoes.length} seção(ões) recebida(s)',
      );

      state = state.copyWith(
        secoes: secoes,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('MinutaPeticaoViewModel: erro ao gerar petição: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao gerar a minuta de petição. Tente novamente.',
      );
    }
  }

  /// Atualiza uma seção editada localmente
  void updateSecao(SecaoPeticao secaoEditada) {
    final currentSecoes = state.secoes ?? [];
    final updatedSecoes = currentSecoes.map((secao) {
      return secao.id == secaoEditada.id ? secaoEditada : secao;
    }).toList();

    state = state.copyWith(secoes: updatedSecoes);
  }
}
