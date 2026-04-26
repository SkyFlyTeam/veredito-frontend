import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../petition/domain/entities/peticao.dart';
import '../providers/analysis_precedent_view_model_provider.dart';
import '../providers/pipeline_stream_provider.dart';
import '../widget/PrecedentSuggestedCard.dart';
import '../widget/bottom_sheet_precedent_suggested.dart';
import '../widget/analysis_file_skeleton.dart';
import '../widget/analysis_section_title.dart';
import '../widget/petition_summary_skeleton.dart';
import '../widget/suggestion_cards_skeleton.dart';
import '../widget/suggestion_limit_dropdown.dart';
import '../view_models/analysis_precedent_state.dart';
import '../../../data/models/pipeline_event_model.dart';

class AnalysisPrecedentScreen extends ConsumerStatefulWidget {
  final Peticao? petition;

  const AnalysisPrecedentScreen({super.key, this.petition});

  @override
  ConsumerState<AnalysisPrecedentScreen> createState() =>
      _AnalysisPrecedentScreenState();
}

class _AnalysisPrecedentScreenState
    extends ConsumerState<AnalysisPrecedentScreen> {
  late final AnalysisPrecedentState _initialState;

  @override
  void initState() {
    super.initState();
    _initialState = AnalysisPrecedentState.initial(petition: widget.petition);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(analysisPrecedentViewModelProvider(_initialState).notifier)
          .initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const suggestionLimitOptions = [1, 5, 10];

    final state = ref.watch(analysisPrecedentViewModelProvider(_initialState));
    final viewModel = ref.read(
      analysisPrecedentViewModelProvider(_initialState).notifier,
    );

    final peticaoId = widget.petition?.id;

    if (peticaoId != null) {
      ref.listen(streamPipelineProvider(peticaoId), (_, next) {
        next.whenData((event) {
          if (event is SearchEvent) {
            debugPrint('SearchEvent: ${event.precedents.length} precedentes');
            for (final p in event.precedents) {
              debugPrint(
                '  precedent.id: ${p.id} | score: ${p.score} | percentual: ${p.percentualSimilaridade}',
              );
            }
            ref.read(precedentsMapProvider.notifier).state = {
              for (var p in event.precedents) p.id: p,
            };
          } else if (event is SynthesisEvent) {
            debugPrint(
              'SynthesisEvent | id: ${event.id} | precedenteId: ${event.precedenteId} | classificacao: ${event.classificacao}',
            );
            ref
                .read(synthesisMapProvider.notifier)
                .update((map) => {...map, event.precedenteId: event});
          }
        });
      });
    }

    final precedentsMap = ref.watch(precedentsMapProvider);
    final synthesisMap = ref.watch(synthesisMapProvider);

    final hasSSEData = precedentsMap.isNotEmpty;
    final isSSELoading =
        peticaoId != null &&
        precedentsMap.isEmpty &&
        !state.isSuggestionsLoading;

    final visibleSSEPrecedents = precedentsMap.values
        .take(state.selectedLimit)
        .toList();

    // Log para verificar se IDs batem
    for (final p in visibleSSEPrecedents) {
      final synthesis = synthesisMap[p.id];
      debugPrint(
        'Card | precedent.id: ${p.id} | synthesis.classificacao: ${synthesis?.classificacao}',
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalysisSectionTitle(
            title: 'Analisando Arquivo',
            textTheme: textTheme,
          ),
          const SizedBox(height: 12),
          if (state.isFileLoading)
            const AnalysisFileSkeleton()
          else
            _buildFileCard(state.documentDisplayName, textTheme),
          const SizedBox(height: 28),

          // Seção de resumo — mantida para uso futuro
          if (state.isSummaryLoading) ...[
            AnalysisSectionTitle(
              title: 'Síntese da Petição',
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            const PetitionSummarySkeleton(),
            const SizedBox(height: 28),
          ] else if (state.petitionSummary != null &&
              state.petitionSummary!.isNotEmpty) ...[
            AnalysisSectionTitle(
              title: 'Síntese da Petição',
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(state.petitionSummary!, textTheme),
            const SizedBox(height: 28),
          ],

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

          if (isSSELoading)
            _buildProcessingCard(textTheme)
          else if (hasSSEData)
            _buildSSEList(visibleSSEPrecedents, synthesisMap)
          else if (state.isSuggestionsLoading)
            const SuggestionCardsSkeleton()
          else if (state.visibleSuggestions.isEmpty)
            _buildEmptyCard(textTheme)
          else
            _buildDBList(state.visibleSuggestions),
        ],
      ),
    );
  }

  Widget _buildFileCard(String fileName, TextTheme textTheme) {
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
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray100,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String summary, TextTheme textTheme) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
        child: Text(
          summary,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.gray100,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.5,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingCard(TextTheme textTheme) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.purple100,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Processando...',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.purple100,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSSEList(
    List<PrecedentBackendDto> precedents,
    Map<int, SynthesisEvent> synthesisMap,
  ) {
    return Column(
      children: [
        for (var index = 0; index < precedents.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == precedents.length - 1 ? 0 : 12,
            ),
            child: PrecedentSuggestedCard.fromSSE(
              key: ValueKey('sse_${precedents[index].id}'),
              precedent: precedents[index],
              synthesis: synthesisMap[precedents[index].id],
            ),
          ),
      ],
    );
  }

  Widget _buildDBList(List suggestions) {
    return Column(
      children: [
        for (var index = 0; index < suggestions.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == suggestions.length - 1 ? 0 : 12,
            ),
            child: PrecedentSuggestedCard.fromSuggested(
              key: ValueKey('db_${suggestions[index].id}'),
              suggestedPrecedent: suggestions[index],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyCard(TextTheme textTheme) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Text(
          'Nenhum precedente sugerido no momento.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.gray100,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.35,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}