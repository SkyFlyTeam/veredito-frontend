import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/entities/tribunal_precedente.dart';
import '../../../../../domain/use_cases/filters_use_case.dart';
import 'tribunais_filter_state.dart';

class TribunaisFilterViewModel extends StateNotifier<TribunaisFilterState> {
  final FiltersUseCase _filtersUseCase;
  bool _didLoad = false;

  TribunaisFilterViewModel(this._filtersUseCase) : super(const TribunaisFilterState());

  Future<void> initialize({Set<int>? initialSelectedIds}) async {
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    await _load(initialSelectedIds: initialSelectedIds);
  }

  Future<void> retry() async {
    await _load(initialSelectedIds: state.selectedIds);
  }

  void setQuery(String value) {
    state = state.copyWith(query: value.trim().toLowerCase());
  }

  void toggleGroupExpansion(String groupId) {
    final expanded = {...state.expandedGroupIds};
    if (expanded.contains(groupId)) {
      expanded.remove(groupId);
    } else {
      expanded.add(groupId);
    }

    state = state.copyWith(expandedGroupIds: expanded);
  }

  void toggleGroupSelection(TribunalFilterGroup group) {
    final selected = {...state.selectedIds};
    final optionIds = group.options.map((option) => option.id).toList();
    final isSelectingAll = !group.isFullySelected(selected);

    if (isSelectingAll) {
      selected.addAll(optionIds);
    } else {
      selected.removeWhere(optionIds.contains);
    }

    state = state.copyWith(selectedIds: selected);
  }

  void toggleOption(int optionId) {
    final selected = {...state.selectedIds};
    if (selected.contains(optionId)) {
      selected.remove(optionId);
    } else {
      selected.add(optionId);
    }

    state = state.copyWith(selectedIds: selected);
  }

  List<TribunalPrecedente> selectedTribunais() {
    final selected = <TribunalPrecedente>[];
    for (final group in state.groups) {
      for (final option in group.options) {
        if (state.selectedIds.contains(option.id)) {
          selected.add(option.tribunal);
        }
      }
    }
    return selected;
  }

  Future<void> _load({Set<int>? initialSelectedIds}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final tribunais = await _filtersUseCase.getTribunais();
      final groups = _buildGroups(tribunais);
      final selectedIds = initialSelectedIds ?? <int>{};
      final expandedGroupIds = _initialExpandedGroups(groups);

      state = state.copyWith(
        isLoading: false,
        groups: groups,
        selectedIds: selectedIds,
        expandedGroupIds: expandedGroupIds,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Nao foi possivel carregar os tribunais.',
      );
    }
  }

  List<TribunalFilterGroup> _buildGroups(List<TribunalPrecedente> tribunais) {
    final grouped = <String, List<TribunalFilterItem>>{};
    for (final tribunal in tribunais) {
      final groupId = _groupIdFor(tribunal.sigla);
      grouped.putIfAbsent(groupId, () => []);
      grouped[groupId]!.add(_mapOption(tribunal));
    }

    final orderedIds = _groupOrder();
    final groups = <TribunalFilterGroup>[];
    for (final id in orderedIds) {
      final options = grouped[id];
      if (options == null || options.isEmpty) {
        continue;
      }
      options.sort((a, b) => a.label.compareTo(b.label));
      groups.add(
        TribunalFilterGroup(
          id: id,
          label: _groupLabel(id),
          initiallyExpanded: groups.isEmpty,
          options: options,
        ),
      );
    }

    return groups;
  }

  TribunalFilterItem _mapOption(TribunalPrecedente tribunal) {
    final label = tribunal.sigla.trim().isNotEmpty ? tribunal.sigla : tribunal.nome;
    return TribunalFilterItem(id: tribunal.id, label: label, tribunal: tribunal);
  }

  Set<String> _initialExpandedGroups(List<TribunalFilterGroup> groups) {
    final expanded = groups
        .where((group) => group.initiallyExpanded)
        .map((group) => group.id)
        .toSet();

    if (expanded.isEmpty && groups.isNotEmpty) {
      expanded.add(groups.first.id);
    }
    return expanded;
  }

  String _groupIdFor(String sigla) {
    final normalized = sigla.trim().toUpperCase();
    if (normalized.startsWith('TRF')) return 'trfs';
    if (normalized.startsWith('TRT')) return 'trts';
    if (normalized.startsWith('TJ')) return 'tjs';
    if (normalized.startsWith('TRE')) return 'tres';
    if (normalized.startsWith('TJM')) return 'tjms';
    if (normalized == 'STF' ||
        normalized == 'STJ' ||
        normalized == 'TSE' ||
        normalized == 'TST' ||
        normalized == 'STM') {
      return 'superiores';
    }
    return 'outros';
  }

  List<String> _groupOrder() {
    return const ['superiores', 'trfs', 'tjs', 'trts', 'tres', 'tjms', 'outros'];
  }

  String _groupLabel(String id) {
    switch (id) {
      case 'superiores':
        return 'Superiores';
      case 'trfs':
        return 'TRFs';
      case 'tjs':
        return 'TJs';
      case 'trts':
        return 'TRTs';
      case 'tres':
        return 'TREs';
      case 'tjms':
        return 'TJMs';
      default:
        return 'Outros';
    }
  }
}
