import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../shared/widgets/bottom_sheet.dart';
import '../../../../domain/entities/especie_precedente.dart';
import '../../../../domain/entities/tribunal_precedente.dart';
import 'especies_filter.dart';
import 'tribunais_filter.dart';

typedef FiltersApplied = void Function({
	required List<TribunalPrecedente> tribunais,
	required List<EspeciePrecedente> especies,
});

enum _FiltersBottomSheetView {
	defaultView,
	tribunais,
	especies,
}

class FiltersBottomSheet extends StatefulWidget {
	final FiltersApplied? onApply;
	final List<TribunalPrecedente> initialTribunais;
	final List<EspeciePrecedente> initialEspecies;

	const FiltersBottomSheet({
		super.key,
		this.onApply,
		this.initialTribunais = const [],
		this.initialEspecies = const [],
	});

	static Future<T?> show<T>(
		BuildContext context, {
		FiltersApplied? onApply,
		List<TribunalPrecedente> initialTribunais = const [],
		List<EspeciePrecedente> initialEspecies = const [],
	}) {
		return AppBottomSheet.show<T>(
			context,
			bodyBuilder: (_) => FiltersBottomSheet(
				onApply: onApply,
				initialTribunais: initialTribunais,
				initialEspecies: initialEspecies,
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
	late List<TribunalPrecedente> _tribunaisSelection;
	late List<EspeciePrecedente> _especiesSelection;

	@override
	void initState() {
		super.initState();
		_tribunaisSelection = List<TribunalPrecedente>.from(widget.initialTribunais);
		_especiesSelection = List<EspeciePrecedente>.from(widget.initialEspecies);
	}

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

	void _openEspecies() {
		setState(() {
			_view = _FiltersBottomSheetView.especies;
		});
	}

	void _handleTribunaisApply(List<TribunalPrecedente> selected) {
		setState(() {
			_tribunaisSelection = selected;
			_view = _FiltersBottomSheetView.defaultView;
		});
		_notifyApply();
	}

	void _handleEspeciesApply(List<EspeciePrecedente> selected) {
		setState(() {
			_especiesSelection = selected;
			_view = _FiltersBottomSheetView.defaultView;
		});
		_notifyApply();
	}

	void _notifyApply() {
		widget.onApply?.call(
			tribunais: _tribunaisSelection,
			especies: _especiesSelection,
		);
	}

	@override
	Widget build(BuildContext context) {
		if (_view == _FiltersBottomSheetView.tribunais) {
			return TribunaisFilter(
				initialSelectedTribunais: _tribunaisSelection,
				onApply: _handleTribunaisApply,
				onCancel: _openDefault,
			);
		}

		if (_view == _FiltersBottomSheetView.especies) {
			return EspeciesFilter(
				initialSelectedEspecies: _especiesSelection,
				onApply: _handleEspeciesApply,
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
						style: Theme.of(context).textTheme.titleMedium?.copyWith(
							color: AppColors.gray100,
							fontWeight: FontWeight.w700,
							height: 1.1,
							letterSpacing: -0.4,
						),
					),
					const SizedBox(height: 30),
					_FilterOptionTile(
						label: 'Tribunais',
						onTap: _openTribunais,
					),
					const SizedBox(height: 25),
					_FilterOptionTile(
						label: 'Espécies',
						onTap: _openEspecies,
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
			color: AppColors.purple300.withValues(alpha: 0.30),
			borderRadius: BorderRadius.circular(14),
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(14),
				child: Container(
					padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
					child: Row(
						children: [
							Expanded(
								child: Text(
									label,
									style: Theme.of(context).textTheme.bodyLarge?.copyWith(
										color: AppColors.gray100,
										fontWeight: FontWeight.w700,
										height: 1.1,
										letterSpacing: -0.2,
									),
								),
							),
							const Icon(
								Icons.chevron_right_rounded,
								size: 25,
								color: AppColors.gray100,
							),
						],
					),
				),
			),
		);
	}
}
