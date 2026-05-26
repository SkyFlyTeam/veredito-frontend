import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../shared/widgets/search_input.dart';

import '../../../../domain/entities/tribunal_precedente.dart';
import 'providers/tribunais_filter_providers.dart';
import 'view_models/tribunais_filter_state.dart';

class TribunaisFilter extends ConsumerStatefulWidget {
	final List<TribunalPrecedente>? initialSelectedTribunais;
	final ValueChanged<List<TribunalPrecedente>> onApply;
	final VoidCallback? onCancel;

	const TribunaisFilter({
		super.key,
		required this.onApply,
		this.initialSelectedTribunais,
		this.onCancel,
	});

	@override
	ConsumerState<TribunaisFilter> createState() => _TribunaisFilterState();
}

class _TribunaisFilterState extends ConsumerState<TribunaisFilter> {
	final TextEditingController _searchController = TextEditingController();

	@override
	void initState() {
		super.initState();
		final initialIds = widget.initialSelectedTribunais
			?.map((tribunal) => tribunal.id)
			.toSet();
		Future.microtask(() {
			ref
				.read(tribunaisFilterViewModelProvider.notifier)
				.initialize(initialSelectedIds: initialIds);
		});
	}

	@override
	void dispose() {
		_searchController.dispose();
		super.dispose();
	}

	void _handleApply() {
		final selectedTribunais = ref
			.read(tribunaisFilterViewModelProvider.notifier)
			.selectedTribunais();
		widget.onApply(selectedTribunais);
	}

	@override
	Widget build(BuildContext context) {
		final bottomInset = MediaQuery.of(context).viewPadding.bottom;
		final state = ref.watch(tribunaisFilterViewModelProvider);
		final viewModel = ref.read(tribunaisFilterViewModelProvider.notifier);

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
						style: Theme.of(context).textTheme.titleMedium?.copyWith(
							color: AppColors.gray100,
							fontWeight: FontWeight.w700,
							height: 1.1,
							letterSpacing: -0.4,
						),
					),
					const SizedBox(height: 30),
					SearchInput(
						controller: _searchController,
						hintText: 'Buscar',
						onChanged: viewModel.setQuery,
						onClear: () => viewModel.setQuery(''),
					),
					const SizedBox(height: 26),
					if (state.isLoading)
						const Padding(
							padding: EdgeInsets.symmetric(vertical: 36),
							child: Center(
								child: CircularProgressIndicator(
									color: AppColors.purple100,
								),
							),
						)
					else if (state.errorMessage != null)
						Padding(
							padding: const EdgeInsets.symmetric(vertical: 28),
							child: Column(
								children: [
									Text(
										state.errorMessage!,
										textAlign: TextAlign.center,
										style: Theme.of(context).textTheme.bodyMedium?.copyWith(
											color: AppColors.gray100,
											fontSize: 14,
										),
									),
									const SizedBox(height: 16),
									TextButton(
										onPressed: viewModel.retry,
										child: const Text('Tentar novamente'),
									),
								],
							),
						)
					else ...[
						...state.visibleGroups().map(
							(group) => Padding(
								padding: const EdgeInsets.only(bottom: 18),
								child: _TribunalGroupTile(
									group: group,
									isExpanded: state.query.isNotEmpty ||
										state.expandedGroupIds.contains(group.id),
									onToggleExpansion: group.options.isEmpty
										? null
										: () => viewModel.toggleGroupExpansion(group.id),
									onToggleGroupSelection: group.options.isEmpty
										? null
										: () => viewModel.toggleGroupSelection(group),
									onToggleOption: viewModel.toggleOption,
									selectedIds: state.selectedIds,
								),
							),
						),
						const SizedBox(height: 14),
						SizedBox(
							height: 50,
							child: ElevatedButton(
								onPressed: _handleApply,
								style: ElevatedButton.styleFrom(
									backgroundColor: AppColors.purple200,
									foregroundColor: AppColors.gray100,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(10),
									),
									elevation: 0,
								),
								child: Text(
									'Aplicar',
									style: Theme.of(context).textTheme.bodyLarge?.copyWith(
										color: AppColors.gray100,
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

class _TribunalGroupTile extends StatelessWidget {
	final TribunalFilterGroup group;
	final bool isExpanded;
	final VoidCallback? onToggleExpansion;
	final VoidCallback? onToggleGroupSelection;
	final ValueChanged<int> onToggleOption;
	final Set<int> selectedIds;

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
									activeColor: AppColors.purple200,
									checkColor: AppColors.gray100,
									side: const BorderSide(color: AppColors.purple200, width: 1.4),
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(4),
									),
									materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
								),
								const SizedBox(width: 6),
								Expanded(
									child: Text(
										group.label,
										style: Theme.of(context).textTheme.bodyMedium?.copyWith(
											color: AppColors.gray100,
											fontWeight: FontWeight.w800,
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
							activeColor: AppColors.purple200,
							checkColor: AppColors.gray100,
							side: const BorderSide(color: AppColors.purple200, width: 1.4),
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(4),
							),
							materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
						),
						const SizedBox(width: 8),
						Text(
							option.label,
							style: Theme.of(context).textTheme.bodyMedium?.copyWith(
								color: AppColors.gray100,
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