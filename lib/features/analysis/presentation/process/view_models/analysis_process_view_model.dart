import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/precedent_stream_events/error_event.dart';
import '../../../domain/entities/precedent_stream_events/search_event.dart';
import '../../../domain/entities/precedent_stream_events/synthesis_event.dart';
import '../../../domain/entities/precedent_suggested.dart';
import '../../../domain/entities/process_stream_events/general_info_event.dart';
import '../../../domain/entities/process_stream_events/pecas_event.dart';
import 'analysis_process_state.dart';

class AnalysisProcessViewModel extends StateNotifier<AnalysisProcessState> {
  AnalysisProcessViewModel(super.initialState);

  void handleGeneralInfoEvent(GeneralInfoEvent event) {
    debugPrint(
      'AnalysisProcessViewModel: received GeneralInfoEvent, fatos_len=${event.fatos.length}',
    );

    state = state.copyWith(
      fatos: event.fatos,
      fundamentosJuridicos: event.fundamentosJuridicos,
      pedidos: event.pedidos,
      isGeneralInfoLoadingOverride: false,
    );
  }

  void handlePecasEvent(PecasEvent event) {
    debugPrint(
      'AnalysisProcessViewModel: received PecasEvent, pecas=${event.pecas.length}',
    );

    state = state.copyWith(
      pecas: event.pecas,
      isPiecesLoadingOverride: false,
    );
  }

  void handleSearchEvent(SearchEvent event) {
    debugPrint(
      'AnalysisProcessViewModel: received SearchEvent, precedents=${event.precedents.length}, avg_score=${event.averageSimilarityScore}',
    );

    state = state.copyWith(
      suggestions: event.precedents,
      isSuggestionsLoadingOverride: false,
    );
  }

  void handleSynthesisEvent(SynthesisEvent event) {
    debugPrint(
      'AnalysisProcessViewModel: received SynthesisEvent, precedent_id=${event.precedenteId}, classificacao=${event.classificacao}',
    );

    final currentSuggestions = state.suggestions ?? [];
    final updatedSuggestions = currentSuggestions.map((suggestion) {
      if (suggestion.precedentId == event.precedenteId) {
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
      }
      return suggestion;
    }).toList();

    state = state.copyWith(suggestions: updatedSuggestions);
  }

  void handleErrorEvent(ErrorEvent event) {
    debugPrint(
      'AnalysisProcessViewModel: received ErrorEvent, failed_stage=${event.failedStage}, message=${event.message}, error_code=${event.errorCode}',
    );
  }

  void setSelectedLimit(int value) {
    if (state.selectedLimit == value) {
      return;
    }

    state = state.copyWith(selectedLimit: value);
  }
}
