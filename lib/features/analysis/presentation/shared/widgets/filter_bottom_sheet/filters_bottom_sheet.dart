import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../shared/widgets/bottom_sheet.dart';
import 'tribunais_filter.dart';

typedef TribunaisFilterLoader = Future<List<TribunalFilterGroup>> Function();
typedef TribunaisFilterApplied = void Function(TribunaisFilterResult result);

enum _FiltersBottomSheetView {
	defaultView,
	tribunais,
}

class FiltersBottomSheet extends StatefulWidget {
	final VoidCallback? onEspeciesTap;
	final TribunaisFilterLoader? loadTribunaisGroups;
	final TribunaisFilterApplied? onTribunaisApply;

	const FiltersBottomSheet({
		super.key,
		this.onEspeciesTap,
		this.loadTribunaisGroups,
		this.onTribunaisApply,
	});

	static Future<T?> show<T>(
		BuildContext context, {
		VoidCallback? onEspeciesTap,
		TribunaisFilterLoader? loadTribunaisGroups,
		TribunaisFilterApplied? onTribunaisApply,
	}) {
		return AppBottomSheet.show<T>(
			context,
			bodyBuilder: (_) => FiltersBottomSheet(
				onEspeciesTap: onEspeciesTap,
				loadTribunaisGroups: loadTribunaisGroups,
				onTribunaisApply: onTribunaisApply,
			),
			maxHeightFactor: 0.82,
			heightBuffer: 72,
			backgroundColor: AppColors.blue900,
			borderColor: AppColors.gray200.withValues(alpha: 0.7),
		);
	}

	@override
	State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
	_FiltersBottomSheetView _view = _FiltersBottomSheetView.defaultView;
	TribunaisFilterResult? _tribunaisSelection;

	void _openTribunais() {
		setState(() {
			_view = _FiltersBottomSheetView.tribunais;
		});
	}

	void _openDefault() {
		setState(() {
			_view = _FiltersBottomSheetView.defaultView;
		});
	}

	void _handleTribunaisApply(TribunaisFilterResult result) {
		setState(() {
			_tribunaisSelection = result;
			_view = _FiltersBottomSheetView.defaultView;
		});
		widget.onTribunaisApply?.call(result);
	}

	@override
	Widget build(BuildContext context) {
		if (_view == _FiltersBottomSheetView.tribunais) {
			return TribunaisFilter(
				loadGroups: widget.loadTribunaisGroups,
				initialSelectedIds: _tribunaisSelection?.selectedIds,
				onApply: _handleTribunaisApply,
				onCancel: _openDefault,
			);
		}

		return Padding(
			padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.stretch,
				children: [
					const SizedBox(height: 6),
					Text(
						'Filtros',
						textAlign: TextAlign.center,
						style: Theme.of(context).textTheme.headlineMedium?.copyWith(
							color: AppColors.gray100,
							fontSize: 30,
							fontWeight: FontWeight.w700,
							height: 1.1,
							letterSpacing: -0.4,
						),
					),
					const SizedBox(height: 34),
					_FilterOptionTile(
						label: 'Tribunais',
						onTap: _openTribunais,
					),
					const SizedBox(height: 38),
					_FilterOptionTile(
						label: 'Espécies',
						onTap: widget.onEspeciesTap,
					),
				],
			),
		);
	}
}

class _FilterOptionTile extends StatelessWidget {
	final String label;
	final VoidCallback? onTap;

	const _FilterOptionTile({
		required this.label,
		this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		return Material(
			color: AppColors.purple800,
			borderRadius: BorderRadius.circular(14),
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(14),
				child: Container(
					padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(14),
						border: Border.all(
							color: AppColors.purple700.withValues(alpha: 0.28),
							width: 1,
						),
					),
					child: Row(
						children: [
							Expanded(
								child: Text(
									label,
									style: Theme.of(context).textTheme.titleMedium?.copyWith(
										color: AppColors.gray100,
										fontSize: 22,
										fontWeight: FontWeight.w700,
										height: 1.1,
										letterSpacing: -0.2,
									),
								),
							),
							const Icon(
								Icons.chevron_right_rounded,
								size: 34,
								color: AppColors.gray100,
							),
						],
					),
				),
			),
		);
	}
}
