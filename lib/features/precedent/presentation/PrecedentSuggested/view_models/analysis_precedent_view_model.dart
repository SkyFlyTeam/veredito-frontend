import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analysis_precedent_state.dart';

class AnalysisPrecedentViewModel
    extends StateNotifier<AnalysisPrecedentState> {
  AnalysisPrecedentViewModel(AnalysisPrecedentState initialState)
    : super(initialState);

  void setSelectedLimit(int value) {
    if (state.selectedLimit == value) {
      return;
    }

    state = state.copyWith(selectedLimit: value);
  }
}
