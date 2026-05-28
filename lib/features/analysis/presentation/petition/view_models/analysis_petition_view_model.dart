import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/precedent_stream_events/error_event.dart';
import '../../../domain/entities/precedent_stream_events/resumo_event.dart';
import '../../../domain/entities/precedent_stream_events/search_event.dart';
import '../../../domain/entities/precedent_stream_events/synthesis_event.dart';
import '../../../domain/entities/precedent_suggested.dart';
import 'analysis_petition_state.dart';

class AnalysisPetitionViewModel extends StateNotifier<AnalysisPetitionState> {
  AnalysisPetitionViewModel(super.initialState);

  /// Processes a ResumoEvent from the pipeline stream
  ///
  /// Updates the summary with the received resumo.
  /// Sets summary loading override to false to indicate data is available.
  void handleResumoEvent(ResumoEvent event) {
    debugPrint(
      'AnalysisPetitionViewModel: received ResumoEvent, resumo length=${event.resumo.length}',
    );

    state = state.copyWith(
      summary: event.resumo,
      isSummaryLoadingOverride: false,
    );
  }

  /// Processes a SearchEvent from the pipeline stream
  ///
  /// Converts all PrecedenteSugerido to PrecedentSuggested entities
  /// and updates the state with initial suggestions.
  /// Sets suggestions loading override to false.
  void handleSearchEvent(SearchEvent event) {
    debugPrint(
      'AnalysisPetitionViewModel: received SearchEvent, precedents=${event.precedents.length}, avg_score=${event.averageSimilarityScore}',
    );

    state = state.copyWith(
      suggestions: event.precedents,
      isSuggestionsLoadingOverride: false,
    );
  }

  /// Processes a SynthesisEvent from the pipeline stream
  ///
  /// Updates an existing suggestion with the classification and
  /// explanatory synthesis received from the backend.
  void handleSynthesisEvent(SynthesisEvent event) {
    debugPrint(
      'AnalysisPetitionViewModel: received SynthesisEvent, precedent_id=${event.precedenteId}, classificacao=${event.classificacao}',
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

  /// Processes an ErrorEvent from the pipeline stream
  ///
  /// Logs the error information. In a production app, you might
  /// update state to show an error message to the user.
  void handleErrorEvent(ErrorEvent event) {
    debugPrint(
      'AnalysisPetitionViewModel: received ErrorEvent, failed_stage=${event.failedStage}, message=${event.message}, error_code=${event.errorCode}',
    );

    // TODO: Consider adding an error state to AnalysisPetitionState
    // if you want to display error messages to the user
  }

  void setSelectedLimit(int value) {
    if (state.selectedLimit == value) {
      return;
    }

    state = state.copyWith(selectedLimit: value);
  }
}
