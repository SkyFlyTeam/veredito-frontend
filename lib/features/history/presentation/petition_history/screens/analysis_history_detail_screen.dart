import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../precedent/presentation/PrecedentSuggested/view_models/analysis_precedent_state.dart';
import '../../../../precedent/presentation/PrecedentSuggested/providers/analysis_precedent_view_model_provider.dart';
import '../../../../precedent/presentation/PrecedentSuggested/widget/PrecedentSuggestedCard.dart';
import '../../../../precedent/presentation/PrecedentSuggested/widget/bottom_sheet_precedent_suggested.dart';
import '../../../../precedent/presentation/PrecedentSuggested/widget/analysis_section_title.dart';
import '../../../../precedent/presentation/PrecedentSuggested/widget/suggestion_limit_dropdown.dart';
import '../../../../petition/domain/entities/peticao.dart';
import '../../../domain/entities/history.dart';

class AnalysisHistoryDetailScreen extends ConsumerStatefulWidget {
  final AnalysisHistory entry;

  const AnalysisHistoryDetailScreen({
    super.key,
    required this.entry,
  });

  @override
  ConsumerState<AnalysisHistoryDetailScreen> createState() =>
      _AnalysisHistoryDetailScreenState();
}

class _AnalysisHistoryDetailScreenState
    extends ConsumerState<AnalysisHistoryDetailScreen> {
  late final AnalysisPrecedentState _initialState;

  @override
  void initState() {
    super.initState();

    final peticao = Peticao(
      id: widget.entry.petitionId,
      caminhoArquivo: widget.entry.fileName,
      resumo: widget.entry.resumo,
      createdAt: widget.entry.analyzedAt,
      usuarioId: 0,
    );

    _initialState = AnalysisPrecedentState.initial(
      petition: peticao,
      suggestions: widget.entry.suggestions,
      isFileLoading: false,
      isSummaryLoading: false,
      isSuggestionsLoading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const suggestionLimitOptions = [1, 5, 10];

    final state = ref.watch(
      analysisPrecedentViewModelProvider(_initialState),
    );

    final viewModel = ref.read(
      analysisPrecedentViewModelProvider(_initialState).notifier,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Arquivo ────────────────────────────────────────────────────
          AnalysisSectionTitle(
            title: 'Arquivo Analisado',
            textTheme: textTheme,
          ),
          const SizedBox(height: 12),
          _buildFileCard(textTheme),
          const SizedBox(height: 28),

          // ── Síntese ────────────────────────────────────────────────────
          if (state.petitionSummary != null) ...[
            AnalysisSectionTitle(
              title: 'Síntese da Petição',
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(state, textTheme),
            const SizedBox(height: 28),
          ],

          // ── Precedentes com seletor ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AnalysisSectionTitle(
                  title: 'Precedentes Sugeridos',
                  textTheme: textTheme,
                ),
              ),
              SuggestionLimitDropdown(
                value: state.selectedLimit,
                options: suggestionLimitOptions,
                onChanged: (value) {
                  if (value == null) return;
                  viewModel.setSelectedLimit(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSuggestions(state, textTheme, context),
        ],
      ),
    );
  }

  Widget _buildFileCard(TextTheme textTheme) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.insert_drive_file_rounded,
              size: 34,
              color: AppColors.gray100,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.entry.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray100,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    AnalysisPrecedentState state,
    TextTheme textTheme,
  ) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
        child: Text(
          state.petitionSummary!,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.gray100,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(
    AnalysisPrecedentState state,
    TextTheme textTheme,
    BuildContext context,
  ) {
    if (state.visibleSuggestions.isEmpty) {
      return GlassCard(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Text(
            'Nenhum precedente encontrado nesta análise.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.gray100),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < state.visibleSuggestions.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == state.visibleSuggestions.length - 1 ? 0 : 12,
            ),
            child: GestureDetector(
              onTap: () => BottomSheetPrecedentSuggested.show(
                context,
                state.visibleSuggestions[i],
                isClassificationLoading: false,
                isSinteseLoading: false,
              ),
              child: PrecedentSuggestedCard(
                suggestedPrecedent: state.visibleSuggestions[i],
                isClassificationLoading: false,
              ),
            ),
          ),
      ],
    );
  }
}