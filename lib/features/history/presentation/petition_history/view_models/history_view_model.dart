import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/use_cases/history_use_cases.dart';
import '../../../domain/entities/history.dart';
import 'history_state.dart';
import 'package:flutter/foundation.dart';
class HistoryViewModel extends StateNotifier<HistoryState> {
  final GetAllHistoryUseCase _getAllHistory;

  HistoryViewModel(this._getAllHistory) : super(const HistoryState()) {
    loadHistory();
  }

Future<void> loadHistory() async {
  state = state.copyWith(isLoading: true);
  try {
    final items = await _getAllHistory.execute();
    state = state.copyWith(items: items, isLoading: false);
  } catch (e) {
    debugPrint('HistoryViewModel: erro ao carregar histórico: $e');
    state = state.copyWith(items: [], isLoading: false);
  }
}

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateDate(DateTime? date) {
    state = date != null
        ? state.copyWith(selectedDate: date)
        : state.copyWith(clearDate: true);
  }
}