import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../../petition/domain/entities/peticao.dart';
import '../../../domain/use_cases/analyze_petition_usecase.dart';
import 'analysis_precedent_state.dart';

class AnalysisPrecedentViewModel
    extends StateNotifier<AnalysisPrecedentState> {
  final AnalyzePetitionUsecase _analyzePetitionUsecase;
  bool _didInitialize = false;

  AnalysisPrecedentViewModel(
    AnalysisPrecedentState initialState, {
    required AnalyzePetitionUsecase analyzePetitionUsecase,
  }) : _analyzePetitionUsecase = analyzePetitionUsecase,
       super(initialState);

  Future<void> initialize() async {
    if (_didInitialize) {
      debugPrint('Analysis initialize skipped: already initialized.');
      return;
    }
    _didInitialize = true;

    final petition = state.petition;
    if (petition == null || petition.id <= 0) {
      debugPrint(
        'Analysis initialize skipped: invalid petition (petition: $petition, id: ${petition?.id}).',
      );
      state = state.copyWith(
        isFileLoadingOverride: false,
        isSummaryLoadingOverride: false,
        isSuggestionsLoadingOverride: false,
      );
      return;
    }

    try {
      debugPrint('Calling analyze endpoint for petition id=${petition.id}');
      final result = await _analyzePetitionUsecase.execute(petition);
      debugPrint(
        'Analyze endpoint success: resumo length=${result.summary?.length ?? 0}, suggestions=${result.suggestions.length}',
      );
      final mergedSummary = result.summary?.trim().isNotEmpty == true
          ? result.summary
          : petition.resumo;
      final updatedPetition = Peticao(
        id: petition.id,
        caminhoArquivo: petition.caminhoArquivo,
        resumo: mergedSummary,
        createdAt: petition.createdAt,
        usuarioId: petition.usuarioId,
      );

      state = state.copyWith(
        petition: updatedPetition,
        suggestions: result.suggestions,
        isFileLoadingOverride: false,
        isSummaryLoadingOverride: false,
        isSuggestionsLoadingOverride: false,
      );
    } catch (error, stackTrace) {
      debugPrint('Analyze endpoint error: $error');
      debugPrintStack(stackTrace: stackTrace);
      state = state.copyWith(
        isFileLoadingOverride: false,
        isSummaryLoadingOverride: false,
        isSuggestionsLoadingOverride: false,
      );
    }
  }

  void setSelectedLimit(int value) {
    if (state.selectedLimit == value) {
      return;
    }

    state = state.copyWith(selectedLimit: value);
  }
}
