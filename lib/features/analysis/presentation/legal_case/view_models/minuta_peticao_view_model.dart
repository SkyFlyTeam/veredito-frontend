import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/legal_case_stream_events/secoes_event.dart';
import '../../../domain/entities/precedent_stream_events/error_event.dart';
import '../../../domain/entities/precedent_stream_events/search_event.dart';
import '../../../domain/entities/precedent_stream_events/synthesis_event.dart';
import '../../../domain/entities/precedent_suggested.dart';
import '../../../domain/entities/secao_peticao.dart';
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
      precedentes: event.precedents,
      isSuggestionsLoadingOverride: false,
      clearError: true,
    );
  }

  void handleSynthesisEvent(SynthesisEvent event) {
    debugPrint(
      'MinutaPeticaoViewModel: received SynthesisEvent, precedent_id=${event.precedenteId}, classificacao=${event.classificacao}',
    );

    final current = state.precedentes ?? [];
    final updated = current.map((suggestion) {
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
    }).where((suggestion) {
      final classificacao = suggestion.classificacao;
      return classificacao == null || classificacao == 2;
    }).toList();

    state = state.copyWith(precedentes: updated);
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

  Future<bool> downloadPeticao() async {
    final legalCase = state.legalCase;
    if (legalCase == null) {
      return false;
    }

    state = state.copyWith(isDownloadingPeticao: true);

    try {
      final bytes = await _downloadPeticaoUseCase.execute(
        legalCaseId: legalCase.id,
      );

      final fileName = 'minuta_peticao_${legalCase.id}.pdf';
      // final savedPath = await _downloadSaver.saveBytes(bytes, fileName);
      // if (savedPath == null || savedPath.isEmpty) {
      //   state = state.copyWith(isDownloadingPeticao: false);
      //   return false;
      // }

      state = state.copyWith(isDownloadingPeticao: false);
      return true;
    } catch (error) {
      debugPrint('MinutaPeticaoViewModel: download error: $error');
      state = state.copyWith(isDownloadingPeticao: false);
      return false;
    }
  }

  void setSelectedLimit(int value) {
    if (state.selectedLimit == value) {
      return;
    }

    state = state.copyWith(selectedLimit: value);
  }
}
