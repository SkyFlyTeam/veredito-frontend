import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/history_state.dart';
import '../view_models/history_view_model.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../routes/app_router.dart';
import '../../../../../shared/widgets/search_input.dart';
import '../../../domain/entities/history.dart';
import '../../widgets/history_card.dart';
import '../providers/history_provider.dart';

class PetitionHistoryScreen extends ConsumerStatefulWidget {
  const PetitionHistoryScreen({super.key});

  @override
  ConsumerState<PetitionHistoryScreen> createState() =>
      _PetitionHistoryScreenState();
}

class _PetitionHistoryScreenState
    extends ConsumerState<PetitionHistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<AnalysisHistory>> _groupByDate(
    List<AnalysisHistory> items,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final grouped = <String, List<AnalysisHistory>>{};

    for (final item in items) {
      final itemDate = DateTime(
        item.analyzedAt.year,
        item.analyzedAt.month,
        item.analyzedAt.day,
      );

      String label;
      if (itemDate == today) {
        label = 'Hoje';
      } else if (itemDate == yesterday) {
        label = 'Ontem';
      } else {
        label =
            '${item.analyzedAt.day.toString().padLeft(2, '0')}/'
            '${item.analyzedAt.month.toString().padLeft(2, '0')}';
      }

      grouped.putIfAbsent(label, () => []).add(item);
    }

    return grouped;
  }

  Future<void> _pickDateFilter() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.purple300,
              onPrimary: Colors.white,
              surface: AppColors.purple800,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}';
      _searchController.text = formatted;
      ref.read(historyViewModelProvider.notifier).updateSearch(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyViewModelProvider);
    final vm = ref.read(historyViewModelProvider.notifier);
    final grouped = _groupByDate(state.filtered);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          child: Text(
            'Histórico de Análises',
            style: textTheme.headlineMedium,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _GlassSearchBox(
                child: SearchInput(
                  controller: _searchController,
                  hintText: 'Buscar',
                  onChanged: vm.updateSearch,
                  onClear: () => vm.updateSearch(''),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _CalendarButton(onTap: _pickDateFilter),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _buildBody(context, state, vm, grouped),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    HistoryState state,
    HistoryViewModel vm,
    Map<String, List<AnalysisHistory>> grouped,
  ) {
    final textTheme = Theme.of(context).textTheme;

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purple300),
      );
    }

    if (grouped.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_rounded,
              color: Colors.white24,
              size: 56,
            ),
            const SizedBox(height: 12),
            Text(
              state.searchQuery.isEmpty
                  ? 'Nenhuma análise realizada ainda.'
                  : 'Nenhum resultado encontrado.',
              style: textTheme.bodyMedium?.copyWith(color: Colors.white38),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.purple300,
      onRefresh: vm.loadHistory,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                entry.key,
                style: textTheme.titleSmall,
              ),
            ),
            for (final item in entry.value)
              HistoryCard(
                id: item.petitionId,
                name: item.fileName,
                createdAt: item.analyzedAt,
                type: 'Petição',
                icon: Icons.description_outlined,
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRouter.peticaoAnalysesHistory,
                    arguments: item,
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}

class _GlassSearchBox extends StatelessWidget {
  final Widget child;
  const _GlassSearchBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.purple200.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gray100.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class _CalendarButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CalendarButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.purple500,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.calendar_month_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}