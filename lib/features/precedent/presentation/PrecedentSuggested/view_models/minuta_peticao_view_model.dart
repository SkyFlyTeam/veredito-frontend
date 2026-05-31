import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../analysis/domain/entities/secao_peticao.dart';
import '../../../../analysis/domain/use_cases/caso_juridico_use_case.dart';
import '../../../../precedent/domain/entities/precedent.dart';
import '../../../../precedent/domain/entities/precedent_suggested.dart';
import 'minuta_peticao_state.dart';

class MinutaPeticaoViewModel extends StateNotifier<MinutaPeticaoState> {
  final CasoJuridicoUseCase _useCase;

  MinutaPeticaoViewModel(this._useCase, MinutaPeticaoState initialState)
      : super(initialState);

  Future<void> initialize() async {
    final casoId = state.peticao.id;

    state = state.copyWith(isMinutaLoading: true, isSuggestionsLoading: true, clearError: true);

    try {
      debugPrint('MinutaPeticaoViewModel: gerando minuta para casoId=$casoId');
      final secoes = await _useCase.gerarPeticao(casoId);

      state = state.copyWith(
        secoes: secoes,
        isMinutaLoading: false,
        // TODO: substituir por chamada real ao backend quando rota estiver disponível
        precedentes: _mockPrecedentes(casoId),
        isSuggestionsLoading: false,
      );
    } catch (e) {
      debugPrint('MinutaPeticaoViewModel: erro ao gerar minuta: $e');
      state = state.copyWith(
        isMinutaLoading: false,
        isSuggestionsLoading: false,
        errorMessage: 'Erro ao gerar a minuta de petição. Tente novamente.',
      );
    }
  }

  void updateSecao(SecaoPeticao secaoEditada) {
    final updated = (state.secoes ?? []).map((s) {
      return s.id == secaoEditada.id ? secaoEditada : s;
    }).toList();
    state = state.copyWith(secoes: updated);
  }

  void setSelectedLimit(int limit) {
    state = state.copyWith(selectedLimit: limit);
  }

  static List<PrecedentSuggested> _mockPrecedentes(int petitionId) {
    return [
      PrecedentSuggested(
        id: 1,
        petitionId: petitionId,
        precedentId: 387,
        percentualSimilaridade: 90.0,
        classificacao: 0,
        sinteseExplicativa: 'Precedente relacionado à cumulação de danos, contexto distinto do presente caso.',
        precedent: Precedent(
          id: 387,
          numeroRegistro: '387',
          tese: 'É lícita a cumulação das indenizações de dano estético e dano moral.',
          ultimaAtualizacao: DateTime(2026, 2, 20, 23, 0),
          tribunalSigla: 'ST3',
          tribunalNome: 'Superior Tribunal de Justiça',
          statusNome: 'Vigente',
          especieNome: 'Súmula',
          especieSigla: 'ST3',
        ),
      ),
      PrecedentSuggested(
        id: 2,
        petitionId: petitionId,
        precedentId: 446,
        percentualSimilaridade: 85.5,
        classificacao: 1,
        sinteseExplicativa: 'Pode ser aplicável ao caso dependendo da análise do contexto fático.',
        precedent: Precedent(
          id: 446,
          numeroRegistro: '446',
          tese: 'É devida a indenização por dano moral em razão de inscrição indevida em cadastro de inadimplentes.',
          ultimaAtualizacao: DateTime(2026, 1, 15, 10, 0),
          tribunalSigla: 'STJ',
          tribunalNome: 'Superior Tribunal de Justiça',
          statusNome: 'Vigente',
          especieNome: 'Súmula',
          especieSigla: 'STJ',
        ),
      ),
      PrecedentSuggested(
        id: 3,
        petitionId: petitionId,
        precedentId: 331,
        percentualSimilaridade: 78.0,
        classificacao: 2,
        sinteseExplicativa: 'Aplicável ao caso: responsabilidade do Estado por ato de agente público.',
        precedent: Precedent(
          id: 331,
          numeroRegistro: '331',
          tese: 'A responsabilidade civil do Estado por atos de seus agentes prescinde da prova da culpa e pode ser afastada por força maior.',
          ultimaAtualizacao: DateTime(2025, 11, 5, 14, 30),
          tribunalSigla: 'STF',
          tribunalNome: 'Supremo Tribunal Federal',
          statusNome: 'Vigente',
          especieNome: 'Súmula',
          especieSigla: 'STF',
        ),
      ),
    ];
  }
}
