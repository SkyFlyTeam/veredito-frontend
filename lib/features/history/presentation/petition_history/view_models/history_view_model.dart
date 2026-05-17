import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/use_cases/history_use_cases.dart';
import '../../../domain/entities/history.dart';
import 'history_state.dart';

class HistoryViewModel extends StateNotifier<HistoryState> {
  final GetAllHistoryUseCase _getAllHistory;
  final SaveHistoryUseCase _saveHistory;
  final DeleteHistoryUseCase _deleteHistory;
  final ClearAllHistoryUseCase _clearAll;

  HistoryViewModel(
    this._getAllHistory,
    this._saveHistory,
    this._deleteHistory,
    this._clearAll,
  ) : super(const HistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    final items = await _getAllHistory.execute();
    state = state.copyWith(items: items, isLoading: false);
  }

  Future<void> saveEntry(AnalysisHistory entry) async {
    await _saveHistory.execute(entry);
    await loadHistory();
  }

  Future<void> deleteEntry(String id) async {
    await _deleteHistory.execute(id);
    await loadHistory();
  }

  Future<void> clearAll() async {
    await _clearAll.execute();
    state = state.copyWith(items: []);
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
