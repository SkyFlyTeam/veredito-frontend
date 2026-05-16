import '../../../domain/entities/history.dart';

class HistoryState {
  final List<AnalysisHistory> items;
  final bool isLoading;
  final String searchQuery;

  const HistoryState({
    this.items = const [],
    this.isLoading = false,
    this.searchQuery = '',
  });

  List<AnalysisHistory> get filtered {
    final q = searchQuery.toLowerCase().trim();
    if (q.isEmpty) return items;
    return items
        .where((e) => e.fileName.toLowerCase().contains(q))
        .toList();
  }

  HistoryState copyWith({
    List<AnalysisHistory>? items,
    bool? isLoading,
    String? searchQuery,
  }) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}