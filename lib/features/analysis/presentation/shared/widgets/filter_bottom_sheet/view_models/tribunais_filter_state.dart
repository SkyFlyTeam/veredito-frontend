import '../../../../../domain/entities/tribunal_precedente.dart';

class TribunaisFilterState {
  final List<TribunalFilterGroup> groups;
  final Set<int> selectedIds;
  final Set<String> expandedGroupIds;
  final String query;
  final bool isLoading;
  final String? errorMessage;

  const TribunaisFilterState({
    this.groups = const [],
    this.selectedIds = const <int>{},
    this.expandedGroupIds = const <String>{},
    this.query = '',
    this.isLoading = false,
    this.errorMessage,
  });

  TribunaisFilterState copyWith({
    List<TribunalFilterGroup>? groups,
    Set<int>? selectedIds,
    Set<String>? expandedGroupIds,
    String? query,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TribunaisFilterState(
      groups: groups ?? this.groups,
      selectedIds: selectedIds ?? this.selectedIds,
      expandedGroupIds: expandedGroupIds ?? this.expandedGroupIds,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<TribunalFilterGroup> visibleGroups() {
    if (query.isEmpty) {
      return groups;
    }

    return groups
        .map((group) => group.filtered(query))
        .whereType<TribunalFilterGroup>()
        .toList(growable: false);
  }
}

class TribunalFilterGroup {
  final String id;
  final String label;
  final bool initiallyExpanded;
  final List<TribunalFilterItem> options;

  const TribunalFilterGroup({
    required this.id,
    required this.label,
    this.initiallyExpanded = false,
    this.options = const [],
  });

  TribunalFilterGroup? filtered(String query) {
    if (query.isEmpty) {
      return this;
    }

    final normalizedQuery = query.trim().toLowerCase();
    final matchesGroup = label.toLowerCase().contains(normalizedQuery);
    final filteredOptions = options
        .where((option) => option.label.toLowerCase().contains(normalizedQuery))
        .toList(growable: false);

    if (!matchesGroup && filteredOptions.isEmpty) {
      return null;
    }

    return TribunalFilterGroup(
      id: id,
      label: label,
      initiallyExpanded: true,
      options: filteredOptions.isEmpty ? options : filteredOptions,
    );
  }

  bool isFullySelected(Set<int> selectedIds) {
    return options.isNotEmpty && options.every((option) => selectedIds.contains(option.id));
  }

  bool isPartiallySelected(Set<int> selectedIds) {
    final selectedCount = options.where((option) => selectedIds.contains(option.id)).length;
    return selectedCount > 0 && selectedCount < options.length;
  }
}

class TribunalFilterItem {
  final int id;
  final String label;
  final TribunalPrecedente tribunal;

  const TribunalFilterItem({
    required this.id,
    required this.label,
    required this.tribunal,
  });
}
