import '../../../domain/entities/history.dart';

class HistoryState {
  final List<AnalysisHistory> items;
  final bool isLoading;
  final String searchQuery;
  final DateTime? selectedDate;

  const HistoryState({
    this.items = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedDate,
  });

  List<AnalysisHistory> get filtered {
    var result = items;

    final q = searchQuery.toLowerCase().trim();
    if (q.isNotEmpty) {
      result = result
          .where((e) => e.fileName.toLowerCase().contains(q))
          .toList();
    }

    if (selectedDate != null) {
      result = result.where((e) {
        return e.analyzedAt.year == selectedDate!.year &&
            e.analyzedAt.month == selectedDate!.month &&
            e.analyzedAt.day == selectedDate!.day;
      }).toList();
    }

    return result;
  }

  HistoryState copyWith({
    List<AnalysisHistory>? items,
    bool? isLoading,
    String? searchQuery,
    DateTime? selectedDate,
    bool clearDate = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDate: clearDate ? null : selectedDate ?? this.selectedDate,
    );
  }
}