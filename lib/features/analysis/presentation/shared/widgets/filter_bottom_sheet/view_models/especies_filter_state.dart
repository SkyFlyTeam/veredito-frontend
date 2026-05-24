import '../../../../../domain/entities/especie_precedente.dart';

class EspeciesFilterState {
  final List<EspecieFilterItem> options;
  final Set<int> selectedIds;
  final String query;
  final bool isLoading;
  final String? errorMessage;

  const EspeciesFilterState({
    this.options = const [],
    this.selectedIds = const <int>{},
    this.query = '',
    this.isLoading = false,
    this.errorMessage,
  });

  EspeciesFilterState copyWith({
    List<EspecieFilterItem>? options,
    Set<int>? selectedIds,
    String? query,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EspeciesFilterState(
      options: options ?? this.options,
      selectedIds: selectedIds ?? this.selectedIds,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<EspecieFilterItem> visibleOptions() {
    if (query.isEmpty) {
      return options;
    }

    final normalizedQuery = query.trim().toLowerCase();
    return options
        .where((option) => option.label.toLowerCase().contains(normalizedQuery))
        .toList(growable: false);
  }
}

class EspecieFilterItem {
  final int id;
  final String label;
  final EspeciePrecedente especie;

  const EspecieFilterItem({
    required this.id,
    required this.label,
    required this.especie,
  });
}
