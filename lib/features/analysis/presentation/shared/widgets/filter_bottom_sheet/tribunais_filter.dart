import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../shared/widgets/search_input.dart';

typedef TribunaisFilterLoader = Future<List<TribunalFilterGroup>> Function();

class TribunaisFilter extends StatefulWidget {
	final TribunaisFilterLoader? loadGroups;
	final Set<String>? initialSelectedIds;
	final ValueChanged<TribunaisFilterResult> onApply;
	final VoidCallback? onCancel;

	const TribunaisFilter({
		super.key,
		required this.onApply,
		this.loadGroups,
		this.initialSelectedIds,
		this.onCancel,
	});

	@override
	State<TribunaisFilter> createState() => _TribunaisFilterState();
}

class _TribunaisFilterState extends State<TribunaisFilter> {
	final TextEditingController _searchController = TextEditingController();

	List<TribunalFilterGroup> _groups = const [];
	Set<String> _selectedIds = <String>{};
	Set<String> _expandedGroupIds = <String>{};
	String _query = '';
	bool _isLoading = true;
	String? _errorMessage;

	@override
	void initState() {
		super.initState();
		_selectedIds = {...?widget.initialSelectedIds};
		_loadGroups();
	}

	@override
	void dispose() {
		_searchController.dispose();
		super.dispose();
	}

	Future<void> _loadGroups() async {
		setState(() {
			_isLoading = true;
			_errorMessage = null;
		});

		try {
			final loader = widget.loadGroups ?? _defaultLoadGroups;
			final groups = await loader();
			if (!mounted) return;
			setState(() {
				_groups = groups;
				if (widget.initialSelectedIds == null && _selectedIds.isEmpty) {
					_selectedIds = _defaultSelectedIds(groups);
				}
				_expandedGroupIds = groups
					.where((group) => group.initiallyExpanded)
					.map((group) => group.id)
					.toSet();
				if (_expandedGroupIds.isEmpty && groups.isNotEmpty) {
					_expandedGroupIds.add(groups.first.id);
				}
				_isLoading = false;
			});
		} catch (error) {
			if (!mounted) return;
			setState(() {
				_isLoading = false;
				_errorMessage = 'Nao foi possivel carregar os tribunais.';
			});
		}
	}

	static Future<List<TribunalFilterGroup>> _defaultLoadGroups() async {
		return const [
			TribunalFilterGroup(
				id: 'trfs',
				label: 'TRFs',
				initiallyExpanded: true,
				options: [
					TribunalFilterItem(id: 'trf1', label: 'TRF1', isSelected: true),
					TribunalFilterItem(id: 'trf2', label: 'TRF2'),
					TribunalFilterItem(id: 'trf3', label: 'TRF3'),
					TribunalFilterItem(id: 'trf4', label: 'TRF4'),
					TribunalFilterItem(id: 'trf5', label: 'TRF5'),
					TribunalFilterItem(id: 'trf6', label: 'TRF6'),
				],
			),
			TribunalFilterGroup(
				id: 'tjs',
				label: 'TJs',
				options: [],
			),
			TribunalFilterGroup(
				id: 'trts',
				label: 'TRTs',
				options: [],
			),
		];
	}

	static Set<String> _defaultSelectedIds(List<TribunalFilterGroup> groups) {
		final selected = <String>{};
		for (final group in groups) {
			for (final option in group.options) {
				if (option.isSelected) {
					selected.add(option.id);
				}
			}
		}
		return selected;
	}

	void _handleSearchChanged(String value) {
		setState(() {
			_query = value.trim().toLowerCase();
		});
	}

	void _toggleGroupExpansion(String groupId) {
		setState(() {
			if (_expandedGroupIds.contains(groupId)) {
				_expandedGroupIds.remove(groupId);
			} else {
				_expandedGroupIds.add(groupId);
			}
		});
	}

	void _toggleGroupSelection(TribunalFilterGroup group) {
		setState(() {
			final optionIds = group.options.map((option) => option.id).toList();
			final isSelectingAll = !group.isFullySelected(_selectedIds);
			if (isSelectingAll) {
				_selectedIds.addAll(optionIds);
			} else {
				_selectedIds.removeWhere(optionIds.contains);
			}
		});
	}

	void _toggleOption(String optionId) {
		setState(() {
			if (_selectedIds.contains(optionId)) {
				_selectedIds.remove(optionId);
			} else {
				_selectedIds.add(optionId);
			}
		});
	}

	List<TribunalFilterGroup> _visibleGroups() {
		if (_query.isEmpty) {
			return _groups;
		}

		return _groups
			.map((group) => group.filtered(_query))
			.whereType<TribunalFilterGroup>()
			.toList(growable: false);
	}

	bool _isExpanded(TribunalFilterGroup group) {
		return _query.isNotEmpty || _expandedGroupIds.contains(group.id);
	}

	void _handleApply() {
		widget.onApply(
			TribunaisFilterResult(
				selectedIds: _selectedIds,
				groups: _groups,
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		final bottomInset = MediaQuery.of(context).viewPadding.bottom;

		return Padding(
			padding: EdgeInsets.fromLTRB(24, 18, 24, 24 + bottomInset),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					const SizedBox(height: 4),
					Text(
						'Tribunais',
						textAlign: TextAlign.center,
						style: Theme.of(context).textTheme.headlineMedium?.copyWith(
							color: AppColors.gray100,
							fontSize: 30,
							fontWeight: FontWeight.w700,
							height: 1.1,
							letterSpacing: -0.4,
						),
					),
					const SizedBox(height: 32),
					SearchInput(
						controller: _searchController,
						hintText: 'Buscar',
						onChanged: _handleSearchChanged,
						onClear: () => _handleSearchChanged(''),
						decoration: InputDecoration(
							hintText: 'Buscar',
							hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
								color: AppColors.gray100.withValues(alpha: 0.7),
								fontSize: 18,
								fontWeight: FontWeight.w500,
							),
							prefixIcon: const Icon(
								Icons.search,
								color: AppColors.gray100,
								size: 28,
							),
							filled: true,
							fillColor: AppColors.blue900,
							contentPadding: const EdgeInsets.symmetric(
								horizontal: 18,
								vertical: 18,
							),
							border: OutlineInputBorder(
								borderRadius: BorderRadius.circular(18),
								borderSide: const BorderSide(
									color: AppColors.gray100,
									width: 1.6,
								),
							),
							enabledBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(18),
								borderSide: const BorderSide(
									color: AppColors.gray100,
									width: 1.6,
								),
							),
							focusedBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(18),
								borderSide: const BorderSide(
									color: AppColors.purple100,
									width: 1.8,
								),
							),
						),
					),
					const SizedBox(height: 26),
					if (_isLoading)
						const Padding(
							padding: EdgeInsets.symmetric(vertical: 36),
							child: Center(
								child: CircularProgressIndicator(
									color: AppColors.purple100,
								),
							),
						)
					else if (_errorMessage != null)
						Padding(
							padding: const EdgeInsets.symmetric(vertical: 28),
							child: Column(
								children: [
									Text(
										_errorMessage!,
										textAlign: TextAlign.center,
										style: Theme.of(context).textTheme.bodyMedium?.copyWith(
											color: AppColors.gray100,
											fontSize: 14,
										),
									),
									const SizedBox(height: 16),
									TextButton(
										onPressed: _loadGroups,
										child: const Text('Tentar novamente'),
									),
								],
							),
						)
					else ...[
						..._visibleGroups().map(
							(group) => Padding(
								padding: const EdgeInsets.only(bottom: 18),
								child: _TribunalGroupTile(
									group: group,
									isExpanded: _isExpanded(group),
									onToggleExpansion: group.options.isEmpty
										? null
										: () => _toggleGroupExpansion(group.id),
									onToggleGroupSelection: group.options.isEmpty
										? null
										: () => _toggleGroupSelection(group),
									onToggleOption: _toggleOption,
									selectedIds: _selectedIds,
								),
							),
						),
						const SizedBox(height: 14),
						SizedBox(
							height: 60,
							child: ElevatedButton(
								onPressed: _handleApply,
								style: ElevatedButton.styleFrom(
									backgroundColor: AppColors.purple300,
									foregroundColor: AppColors.gray100,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(18),
									),
									elevation: 0,
								),
								child: Text(
									'Aplicar',
									style: Theme.of(context).textTheme.titleMedium?.copyWith(
										color: AppColors.gray100,
										fontSize: 18,
										fontWeight: FontWeight.w700,
									),
								),
							),
						),
					],
				],
			),
		);
	}
}

class TribunalFilterResult {
	final Set<String> selectedIds;
	final List<TribunalFilterGroup> groups;

	const TribunalFilterResult({
		required this.selectedIds,
		required this.groups,
	});
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

	bool isFullySelected(Set<String> selectedIds) {
		return options.isNotEmpty && options.every((option) => selectedIds.contains(option.id));
	}

	bool isPartiallySelected(Set<String> selectedIds) {
		final selectedCount = options.where((option) => selectedIds.contains(option.id)).length;
		return selectedCount > 0 && selectedCount < options.length;
	}
}

class TribunalFilterItem {
	final String id;
	final String label;
	final bool isSelected;

	const TribunalFilterItem({
		required this.id,
		required this.label,
		this.isSelected = false,
	});
}

class _TribunalGroupTile extends StatelessWidget {
	final TribunalFilterGroup group;
	final bool isExpanded;
	final VoidCallback? onToggleExpansion;
	final VoidCallback? onToggleGroupSelection;
	final ValueChanged<String> onToggleOption;
	final Set<String> selectedIds;

	const _TribunalGroupTile({
		required this.group,
		required this.isExpanded,
		required this.onToggleOption,
		required this.selectedIds,
		this.onToggleExpansion,
		this.onToggleGroupSelection,
	});

	@override
	Widget build(BuildContext context) {
		final hasChildren = group.options.isNotEmpty;
		final groupCheckboxValue = group.isFullySelected(selectedIds)
			? true
			: group.isPartiallySelected(selectedIds)
				? null
				: false;

		return AnimatedSize(
			duration: const Duration(milliseconds: 180),
			curve: Curves.easeOut,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					InkWell(
						onTap: onToggleExpansion,
						borderRadius: BorderRadius.circular(16),
						child: Row(
							children: [
								SizedBox(
									width: 26,
									child: Icon(
										isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
										color: AppColors.gray100,
										size: 28,
									),
								),
								Checkbox(
									value: groupCheckboxValue,
									tristate: true,
									onChanged: onToggleGroupSelection == null ? null : (_) => onToggleGroupSelection!.call(),
									activeColor: AppColors.purple300,
									checkColor: AppColors.gray100,
									side: const BorderSide(color: AppColors.purple300, width: 1.4),
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(4),
									),
									materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
								),
								const SizedBox(width: 6),
								Expanded(
									child: Text(
										group.label,
										style: Theme.of(context).textTheme.titleMedium?.copyWith(
											color: AppColors.gray100,
											fontSize: 20,
											fontWeight: FontWeight.w500,
											height: 1.2,
										),
									),
								),
							],
						),
					),
					if (isExpanded && hasChildren) ...[
						const SizedBox(height: 14),
						Padding(
							padding: const EdgeInsets.only(left: 24),
							child: Wrap(
								spacing: 18,
								runSpacing: 14,
								children: group.options
									.map(
										(option) => _TribunalOptionChip(
											option: option,
											isSelected: selectedIds.contains(option.id),
											onToggle: () => onToggleOption(option.id),
										),
									)
									.toList(growable: false),
							),
						),
					],
					if (isExpanded && !hasChildren)
						Padding(
							padding: const EdgeInsets.only(left: 54, top: 8),
							child: Text(
								'Sem opções carregadas',
								style: Theme.of(context).textTheme.bodySmall?.copyWith(
									color: AppColors.gray100.withValues(alpha: 0.7),
									fontSize: 12,
								),
							),
						),
				],
			),
		);
	}
}

class _TribunalOptionChip extends StatelessWidget {
	final TribunalFilterItem option;
	final bool isSelected;
	final VoidCallback onToggle;

	const _TribunalOptionChip({
		required this.option,
		required this.isSelected,
		required this.onToggle,
	});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onToggle,
			borderRadius: BorderRadius.circular(10),
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 2),
				child: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						Checkbox(
							value: isSelected,
							onChanged: (_) => onToggle(),
							activeColor: AppColors.purple300,
							checkColor: AppColors.gray100,
							side: const BorderSide(color: AppColors.purple300, width: 1.4),
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(4),
							),
							materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
						),
						const SizedBox(width: 8),
						Text(
							option.label,
							style: Theme.of(context).textTheme.bodyLarge?.copyWith(
								color: AppColors.gray100,
								fontSize: 20,
								fontWeight: FontWeight.w400,
								height: 1.2,
							),
						),
					],
				),
			),
		);
	}
}