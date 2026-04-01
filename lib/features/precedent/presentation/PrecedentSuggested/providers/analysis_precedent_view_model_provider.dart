import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'precedent_suggestions_provider.dart';
import '../view_models/analysis_precedent_state.dart';
import '../view_models/analysis_precedent_view_model.dart';

final analysisPrecedentViewModelProvider = StateNotifierProvider.autoDispose
    .family<
      AnalysisPrecedentViewModel,
      AnalysisPrecedentState,
      AnalysisPrecedentState
    >((ref, initialState) {
      final analyzePetitionUsecase = ref.read(analyzePetitionUsecaseProvider);
      return AnalysisPrecedentViewModel(
        initialState,
        analyzePetitionUsecase: analyzePetitionUsecase,
      );
    });
