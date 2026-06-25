import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/legal_case_stream_events/secoes_event.dart';
import '../../../domain/entities/precedent_stream_events/error_event.dart';
import '../../../domain/entities/precedent_stream_events/search_event.dart';
import '../../../domain/entities/precedent_stream_events/synthesis_event.dart';
import '../../../domain/entities/precedent_suggested.dart';
import '../../../domain/entities/secao_peticao.dart';
import '../../../domain/enums/classificacao_aderencia.dart';
import '../../../domain/use_cases/download_legal_case_peticao_use_case.dart';
import '../../../domain/use_cases/update_legal_case_section_use_case.dart';
import 'minuta_peticao_state.dart';

class MinutaPeticaoViewModel extends StateNotifier<MinutaPeticaoState> {
  final UpdateLegalCaseSectionUseCase _updateSectionUseCase;
  final DownloadLegalCasePeticaoUseCase _downloadPeticaoUseCase;

  MinutaPeticaoViewModel(
    super.initialState,
    this._updateSectionUseCase,
    this._downloadPeticaoUseCase,
  );

  void initialize() {
    final legalCase = state.legalCase;
    final hasValidCase = legalCase != null && legalCase.id > 0;
    debugPrint('MinutaPeticaoViewModel: initialize called with legalCaseId=${legalCase?.id}, hasValidCase=$hasValidCase');

    state = state.copyWith(
      isMinutaLoadingOverride: hasValidCase ? true : null,
      isSuggestionsLoadingOverride: hasValidCase ? true : null,
      clearError: true,
    );
  }

  void handleSecoesEvent(SecoesEvent event) {
    debugPrint(
      'MinutaPeticaoViewModel: received SecoesEvent, secoes=${event.secoes.length}',
    );

    state = state.copyWith(
      secoes: event.secoes,
      isMinutaLoadingOverride: false,
      clearError: true,
    );
  }

  void handleSearchEvent(SearchEvent event) {
    debugPrint(
      'MinutaPeticaoViewModel: received SearchEvent, precedents=${event.precedents.length}, avg_score=${event.averageSimilarityScore}',
    );

    state = state.copyWith(
      pendingPrecedentes: event.precedents,
      precedentesTotal: event.precedents.length,
      precedentesSynthesisReceived: 0,
      isSuggestionsLoadingOverride: true,
      clearError: true,
    );
  }

  void handleSynthesisEvent(SynthesisEvent event) {
    debugPrint(
      'MinutaPeticaoViewModel: received SynthesisEvent, precedent_id=${event.precedenteId}, classificacao=${event.classificacao}',
    );

    final current = state.pendingPrecedentes ?? const [];
    if (current.isEmpty) {
      return;
    }

    final updatedPending = current.map((suggestion) {
      final matchesEvent = suggestion.precedentId == event.precedenteId ||
          suggestion.precedent?.id == event.precedenteId;
      if (!matchesEvent) {
        return suggestion;
      }

      return PrecedentSuggested(
        id: event.id,
        entityId: suggestion.entityId,
        precedentId: suggestion.precedentId,
        percentualSimilaridade:
            event.percentualSimilaridade ?? suggestion.percentualSimilaridade,
        classificacao: event.classificacao,
        sinteseExplicativa: event.sinteseExplicativa,
        precedent: suggestion.precedent,
      );
    }).toList();

    final total = state.precedentesTotal ?? updatedPending.length;
    final receivedCount = state.precedentesSynthesisReceived + 1;

    if (receivedCount == 1) {
      state = state.copyWith(isSuggestionsLoadingOverride: false);
    }

    final applicableOnly = updatedPending.where((suggestion) {
      return suggestion.classificacao ==
          ClassificacaoAderencia.aplicavel.value;
    }).toList();

    state = state.copyWith(
      pendingPrecedentes: updatedPending,
      precedentes: applicableOnly,
      precedentesSynthesisReceived: receivedCount,
      isSuggestionsLoadingOverride: receivedCount == 0 ? true : false,
    );
  }

  void handleCompleteEvent() {
    final pending = state.pendingPrecedentes ?? const [];
    final applicableOnly = pending.where((suggestion) {
      return suggestion.classificacao ==
          ClassificacaoAderencia.aplicavel.value;
    }).toList();

    state = state.copyWith(
      precedentes: applicableOnly,
      isSuggestionsLoadingOverride: false,
    );
  }

  void handleErrorEvent(ErrorEvent event) {
    debugPrint(
      'MinutaPeticaoViewModel: received ErrorEvent, failed_stage=${event.failedStage}, message=${event.message}, error_code=${event.errorCode}',
    );

    state = state.copyWith(
      errorMessage: event.message,
      isMinutaLoadingOverride: false,
      isSuggestionsLoadingOverride: false,
    );
  }

  Future<void> updateSecao(SecaoPeticao secaoEditada) async {
    final legalCase = state.legalCase;
    if (legalCase == null) {
      return;
    }

    state = state.copyWith(isUpdatingSecao: true, clearError: true);

    try {
      await _updateSectionUseCase.execute(
        legalCaseId: legalCase.id,
        secaoId: secaoEditada.id,
        conteudo: secaoEditada.conteudo,
      );

      final current = state.secoes;
      if (current != null) {
        final updated = current.map((secao) {
          if (secao.id == secaoEditada.id) {
            return secaoEditada;
          }
          return secao;
        }).toList();

        state = state.copyWith(secoes: updated, isUpdatingSecao: false);
      } else {
        state = state.copyWith(isUpdatingSecao: false);
      }
    } catch (error) {
      debugPrint('MinutaPeticaoViewModel: updateSecao error: $error');
      state = state.copyWith(
        isUpdatingSecao: false,
        errorMessage: 'Nao foi possivel atualizar a secao.',
      );
    }
  }

  Future<Uint8List?> downloadPeticaoBytes() async {
    final legalCase = state.legalCase;
    if (legalCase == null) {
      return null;
    }

    state = state.copyWith(isDownloadingPeticao: true);

    try {
      final bytes = await _downloadPeticaoUseCase.execute(
        legalCaseId: legalCase.id,
      );

      state = state.copyWith(isDownloadingPeticao: false);
      return bytes;
    } catch (error) {
      debugPrint('MinutaPeticaoViewModel: download error: $error');
      state = state.copyWith(isDownloadingPeticao: false);
      return null;
    }
  }

  void setSelectedLimit(int value) {
    if (state.selectedLimit == value) {
      return;
    }

    state = state.copyWith(selectedLimit: value);
  }
}
