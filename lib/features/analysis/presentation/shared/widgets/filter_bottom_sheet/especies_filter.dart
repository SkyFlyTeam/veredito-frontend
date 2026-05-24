import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../shared/widgets/search_input.dart';
import '../../../../domain/entities/especie_precedente.dart';
import 'providers/tribunais_filter_providers.dart';
import 'view_models/especies_filter_state.dart';

class EspeciesFilter extends ConsumerStatefulWidget {
  final List<EspeciePrecedente>? initialSelectedEspecies;
  final ValueChanged<List<EspeciePrecedente>> onApply;
  final VoidCallback? onCancel;

  const EspeciesFilter({
    super.key,
    required this.onApply,
    this.initialSelectedEspecies,
    this.onCancel,
  });

  @override
  ConsumerState<EspeciesFilter> createState() => _EspeciesFilterState();
}

class _EspeciesFilterState extends ConsumerState<EspeciesFilter> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialIds = widget.initialSelectedEspecies
        ?.map((especie) => especie.id)
        .toSet();
    Future.microtask(() {
      ref
          .read(especiesFilterViewModelProvider.notifier)
          .initialize(initialSelectedIds: initialIds);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleApply() {
    final selectedEspecies = ref
        .read(especiesFilterViewModelProvider.notifier)
        .selectedEspecies();
    widget.onApply(selectedEspecies);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final state = ref.watch(especiesFilterViewModelProvider);
    final viewModel = ref.read(especiesFilterViewModelProvider.notifier);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 18, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Text(
            'Espécies',
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
            SizedBox(
              height: 280,
              child: state.visibleOptions().isEmpty
                  ? Center(
                      child: Text(
                        'Sem opcoes carregadas',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray100.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: state.visibleOptions().length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final option = state.visibleOptions()[index];
                        return _EspecieOptionTile(
                          option: option,
                          isSelected: state.selectedIds.contains(option.id),
                          onToggle: () => viewModel.toggleOption(option.id),
                        );
                      },
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

class _EspecieOptionTile extends StatelessWidget {
  final EspecieFilterItem option;
  final bool isSelected;
  final VoidCallback onToggle;

  const _EspecieOptionTile({
    required this.option,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(10),
      child: Row(
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
          Expanded(
            child: Text(
              option.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray100,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
