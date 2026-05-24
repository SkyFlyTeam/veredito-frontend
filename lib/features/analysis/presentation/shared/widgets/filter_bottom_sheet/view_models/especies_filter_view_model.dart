import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/entities/especie_precedente.dart';
import '../../../../../domain/use_cases/filters_use_case.dart';
import 'especies_filter_state.dart';

class EspeciesFilterViewModel extends StateNotifier<EspeciesFilterState> {
  final FiltersUseCase _filtersUseCase;
  bool _didLoad = false;

  EspeciesFilterViewModel(this._filtersUseCase) : super(const EspeciesFilterState());

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

  void toggleOption(int optionId) {
    final selected = {...state.selectedIds};
    if (selected.contains(optionId)) {
      selected.remove(optionId);
    } else {
      selected.add(optionId);
    }

    state = state.copyWith(selectedIds: selected);
  }

  List<EspeciePrecedente> selectedEspecies() {
    return state.options
        .where((option) => state.selectedIds.contains(option.id))
        .map((option) => option.especie)
        .toList(growable: false);
  }

  Future<void> _load({Set<int>? initialSelectedIds}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final especies = await _filtersUseCase.getEspecies();
      final options = _buildOptions(especies);
      final selectedIds = initialSelectedIds ?? <int>{};

      state = state.copyWith(
        isLoading: false,
        options: options,
        selectedIds: selectedIds,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Nao foi possivel carregar as especies.',
      );
    }
  }

  List<EspecieFilterItem> _buildOptions(List<EspeciePrecedente> especies) {
    final options = especies
        .map(_mapOption)
        .toList(growable: false);
    options.sort((a, b) => a.label.compareTo(b.label));
    return options;
  }

  EspecieFilterItem _mapOption(EspeciePrecedente especie) {
    final label = especie.sigla.trim().isNotEmpty ? especie.sigla : especie.nome;
    return EspecieFilterItem(id: especie.id, label: label, especie: especie);
  }
}
