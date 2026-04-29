import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../petition/domain/entities/peticao.dart';
import '../../../data/models/pipeline_event_model.dart';
import '../../../domain/entities/precedent.dart';
import '../../../domain/entities/precedent_suggested.dart';
import 'analysis_precedent_state.dart';

class AnalysisPrecedentViewModel extends StateNotifier<AnalysisPrecedentState> {
  AnalysisPrecedentViewModel(super.initialState);

  /// Processes a ResumoEvent from the pipeline stream
  ///
  /// Updates the petition summary with the received resumo.
  /// Sets summary loading override to false to indicate data is available.
  void handleResumoEvent(ResumoEvent event) {
    debugPrint(
      'AnalysisPrecedentViewModel: received ResumoEvent, resumo length=${event.resumo.length}',
    );

    final currentPetition = state.petition;
    if (currentPetition == null) {
      debugPrint(
        'AnalysisPrecedentViewModel: cannot update summary, petition is null',
      );
      return;
    }

    state = state.copyWith(
      petition: Peticao(
        id: currentPetition.id,
        caminhoArquivo: currentPetition.caminhoArquivo,
        resumo: event.resumo,
        createdAt: currentPetition.createdAt,
        usuarioId: currentPetition.usuarioId,
      ),
      isSummaryLoadingOverride: false,
    );
  }

  /// Processes a SearchEvent from the pipeline stream
  ///
  /// Converts all PrecedentBackendDto to PrecedentSuggested entities
  /// and updates the state with initial suggestions.
  /// Sets suggestions loading override to false.
  void handleSearchEvent(SearchEvent event, int peticaoId) {
    debugPrint(
      'AnalysisPrecedentViewModel: received SearchEvent, precedents=${event.precedents.length}, avg_score=${event.averageSimilarityScore}',
    );

    final suggestions = event.precedents
        .map((dto) => _convertPrecedentBackendDtoToSuggested(dto, peticaoId))
        .toList();

    state = state.copyWith(
      suggestions: suggestions,
      isSuggestionsLoadingOverride: false,
    );
  }

  /// Processes a SynthesisEvent from the pipeline stream
  ///
  /// Updates an existing suggestion with the classification and
  /// explanatory synthesis received from the backend.
  void handleSynthesisEvent(SynthesisEvent event) {
    debugPrint(
      'AnalysisPrecedentViewModel: received SynthesisEvent, precedent_id=${event.precedenteId}, classificacao=${event.classificacao}',
    );

    final currentSuggestions = state.suggestions ?? [];
    final updatedSuggestions = currentSuggestions.map((suggestion) {
      if (suggestion.precedentId == event.precedenteId) {
        return PrecedentSuggested(
          id: event.id,
          petitionId: suggestion.petitionId,
          precedentId: suggestion.precedentId,
          percentualSimilaridade: suggestion.percentualSimilaridade,
          classificacao: event.classificacao,
          sinteseExplicativa: event.sintese_explicativa,
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
      'AnalysisPrecedentViewModel: received ErrorEvent, failed_stage=${event.failedStage}, message=${event.message}, error_code=${event.errorCode}',
    );

    // TODO: Consider adding an error state to AnalysisPrecedentState
    // if you want to display error messages to the user
  }

  /// Processes a CompleteEvent from the pipeline stream
  ///
  /// Logs completion information. This indicates the stream has ended
  /// and all processing is complete.
  void handleCompleteEvent(CompleteEvent event) {
    debugPrint(
      'AnalysisPrecedentViewModel: received CompleteEvent, total_duration_ms=${event.totalDurationMs}, precedents_processed=${event.precedentsProcessed}, synthesis_generated=${event.synthesisGenerated}',
    );
  }

  /// Converts a PrecedentBackendDto to a PrecedentSuggested entity
  ///
  /// This creates the initial suggestion from search results.
  /// The classification and synthesis will be populated later
  /// when SynthesisEvent is received.
  PrecedentSuggested _convertPrecedentBackendDtoToSuggested(
    PrecedentBackendDto dto,
    int peticaoId,
  ) {
    final precedent = _convertDtoToPrecedent(dto);
    final percentualSimilaridade = dto.percentualSimilaridade;

    return PrecedentSuggested(
      id: 0, // Will be set in SynthesisEvent
      petitionId: peticaoId,
      precedentId: dto.id,
      percentualSimilaridade: percentualSimilaridade,
      classificacao: null, // Will be set in SynthesisEvent
      sinteseExplicativa: null, // Will be set in SynthesisEvent
      precedent: precedent,
    );
  }

  /// Converts a PrecedentBackendDto to a Precedent entity
  Precedent _convertDtoToPrecedent(PrecedentBackendDto dto) {
    return Precedent(
      id: dto.id,
      numeroRegistro: dto.numeroRegistro,
      tese: dto.tese,
      questao: dto.questao,
      ultimaAtualizacao: dto.ultimaAtualizacao != null
          ? DateTime.tryParse(dto.ultimaAtualizacao!)
          : null,
      questaoVetor: dto.questao,
      tribunalNome: dto.tribunalNome,
      tribunalSigla: dto.tribunalSigla,
      statusNome: dto.statusNome,
      especieNome: dto.especieNome,
      especieSigla: dto.especieSigla,
    );
  }

  void setSelectedLimit(int value) {
    if (state.selectedLimit == value) {
      return;
    }

    state = state.copyWith(selectedLimit: value);
  }
}
