import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../routes/app_router.dart';
import '../../../../../shared/widgets/search_input.dart';
import '../../../domain/entities/history.dart';
import '../view_models/history_state.dart';
import '../view_models/history_view_model.dart';
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

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final yesterday = today.subtract(
      const Duration(days: 1),
    );

    // Ordena do mais recente para o mais antigo
    final sorted = [...items]
      ..sort(
        (a, b) => b.analyzedAt.compareTo(a.analyzedAt),
      );

    final grouped = <String, List<AnalysisHistory>>{};

    for (final item in sorted) {
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
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.purple500,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              onSurfaceVariant: Colors.black,
            ),
            disabledColor: Colors.black45,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black),
              bodySmall: TextStyle(color: Colors.black),
              labelLarge: TextStyle(color: Colors.black),
              labelSmall: TextStyle(color: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      ref.read(historyViewModelProvider.notifier).updateDate(
            picked,
          );
    }
  }

  // ── [TESTE] Confirmação antes de apagar tudo ───────────────────────────
  // TODO: remover este método quando os testes forem concluídos
  Future<void> _confirmClearAll(
    HistoryViewModel vm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.purple800,
        title: const Text(
          'Apagar tudo?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Todos os registros de histórico serão removidos permanentemente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Apagar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await vm.clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyViewModelProvider);

    final vm = ref.read(
      historyViewModelProvider.notifier,
    );

    final grouped = _groupByDate(state.filtered);

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Título ────────────────────────────────────────────────────────
        Text(
          'Histórico de Análises',
          style: textTheme.headlineMedium,
        ),

        const SizedBox(height: 30),

        // ── Busca + Calendário ───────────────────────────────────────────
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

            _CalendarButton(
              onTap: _pickDateFilter,
            ),
          ],
        ),

        // ── Chip de data selecionada ─────────────────────────────────────
        if (state.selectedDate != null) ...[
          const SizedBox(height: 10),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.purple200,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.purple300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.selectedDate!.day.toString().padLeft(2, '0')}/'
                      '${state.selectedDate!.month.toString().padLeft(2, '0')}/'
                      '${state.selectedDate!.year}',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(width: 6),

                    GestureDetector(
                      onTap: () => vm.updateDate(null),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],

        // ── [TESTE] Ferramentas de teste ─────────────────────────────────
        // TODO: remover este bloco quando os testes forem concluídos

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () async {
              final fakeNames = [
                'Ação Popular',
                'Mandado de Segurança',
                'Execução Fiscal',
                'Ação Civil Pública',
                'Recurso Especial',
                'Apelação Cível',
                'Habeas Corpus',
                'Ação Trabalhista',
                'Pedido Liminar',
                'Contestação',
                'Tutela Antecipada',
                'Embargos à Execução',
                'Agravo de Instrumento',
                'Ação Declaratória',
                'Ação de Cobrança',
              ];

              final now = DateTime.now();

              final seed =
                  DateTime.now().millisecondsSinceEpoch;

              for (var i = 0; i < 20; i++) {
                final name =
                    fakeNames[(seed + i) % fakeNames.length];

                final fakeDate = now.subtract(
                  Duration(
                    days: (seed + i) % 365,
                    hours: (seed + i) % 24,
                    minutes: (seed + i) % 60,
                  ),
                );

                final entry = AnalysisHistory(
                  id:
                      'fake_${DateTime.now().millisecondsSinceEpoch}_$i',
                  petitionId: 1000 + i,
                  fileName: '$name.pdf',
                  resumo:
                      'Resumo fictício gerado apenas para testes.',
                  suggestions: [],
                  analyzedAt: fakeDate,
                );

                await vm.saveEntry(entry);
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Dados simulados adicionados.',
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor:
                  Colors.blue.withValues(alpha: 0.15),
              foregroundColor: Colors.lightBlueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                  color: Colors.lightBlueAccent,
                  width: 1,
                ),
              ),
            ),
            child: const Text('SIMULAR DADOS'),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => _confirmClearAll(vm),
            style: TextButton.styleFrom(
              backgroundColor:
                  Colors.red.withValues(alpha: 0.15),
              foregroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                  color: Colors.redAccent,
                  width: 1,
                ),
              ),
            ),
            child: const Text('APAGAR TUDO'),
          ),
        ),

        // ── [FIM TESTE] ──────────────────────────────────────────────────

        const SizedBox(height: 30),

        // ── Lista ────────────────────────────────────────────────────────
        Expanded(
          child: _buildBody(
            context,
            state,
            vm,
            grouped,
          ),
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
        child: CircularProgressIndicator(
          color: AppColors.purple300,
        ),
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
              state.searchQuery.isEmpty &&
                      state.selectedDate == null
                  ? 'Nenhuma análise realizada ainda.'
                  : 'Nenhum resultado encontrado.',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white38,
              ),
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
              padding: const EdgeInsets.only(
                left: 8,
                bottom: 15,
              ),
              child: Text(
                entry.key,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
                  // ── [TESTE] Bloqueia navegação fake ───────────────
                  // TODO: remover este bloco quando os testes forem concluídos
                  if (item.id.startsWith('fake_')) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor:
                            AppColors.purple800,
                        title: const Text(
                          'Dado Simulado',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        content: const Text(
                          'Este item foi gerado apenas para testes e não possui análise real.',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );

                    return;
                  }

                  // ── [FIM TESTE] ──────────────────────────────────

                  Navigator.of(context).pushNamed(
                    AppRouter.peticaoAnalysesHistory,
                    arguments: item,
                  );
                },
              ),

            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ──────────────────────────────────────────────────

class _GlassSearchBox extends StatelessWidget {
  final Widget child;

  const _GlassSearchBox({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            AppColors.purple200.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              AppColors.gray100.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class _CalendarButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CalendarButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.purple200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.purple200,
            width: 1,
          ),
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