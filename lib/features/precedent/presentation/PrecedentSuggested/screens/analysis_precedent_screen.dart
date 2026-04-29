import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../petition/presentation/petition_upload/providers/petition_upload_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../petition/domain/entities/peticao.dart';
import '../providers/analysis_precedent_view_model_provider.dart';
import '../providers/pipeline_stream_provider.dart';
import '../widget/PrecedentSuggestedCard.dart';
import '../widget/analysis_file_skeleton.dart';
import '../widget/analysis_section_title.dart';
import '../widget/bottom_sheet_precedent_suggested.dart';
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
  late AnalysisPrecedentState _initialState;
  int? _lastPeticaoId;

  @override
  void initState() {
    super.initState();
    _initialState = AnalysisPrecedentState.initial(petition: widget.petition);
    _lastPeticaoId = widget.petition?.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(analysisPrecedentViewModelProvider(_initialState));

      ref
          .read(analysisPrecedentViewModelProvider(_initialState).notifier)
          .initialize();
    });
  }

  @override
  void dispose() {
    ref.invalidate(petitionUploadProvider);
    ref.invalidate(precedentsMapProvider);
    ref.invalidate(synthesisMapProvider);
    ref.invalidate(resumoProvider);
    if (_lastPeticaoId != null) {
      ref.invalidate(streamPipelineProvider(_lastPeticaoId!));
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(AnalysisPrecedentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Se a petição mudou, reseta os dados SSE e re-inicializa
    if (oldWidget.petition?.id != widget.petition?.id) {
      debugPrint('[AnalysisPrecedentScreen] Petição mudou! Limpando estado...');

      // Guarda referência ao estado antigo antes de resetar
      final oldState = _initialState;

      // Invalida o provider antigo para forçar recriação
      if (oldWidget.petition != null) {
        ref.invalidate(analysisPrecedentViewModelProvider(oldState));
      }

      // Limpa os dados SSE
      ref.read(precedentsMapProvider.notifier).state = {};
      ref.read(synthesisMapProvider.notifier).state = {};
      ref.read(resumoProvider.notifier).state = null;

      // Atualiza o rastreamento de ID
      _lastPeticaoId = widget.petition?.id;

      // Reseta o estado inicial com a nova petição
      _initialState = AnalysisPrecedentState.initial(petition: widget.petition);

      // Re-inicializa o view model
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(analysisPrecedentViewModelProvider(_initialState).notifier)
            .initialize();
      });
    }
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

    if (peticaoId != null && peticaoId == _lastPeticaoId) {
      ref.listen(streamPipelineProvider(peticaoId), (_, next) {
        next.whenData((event) {
          if (event is ResumoEvent) {
            debugPrint('ResumoEvent: ${event.resumo.substring(0, 50)}...');
            ref.read(resumoProvider.notifier).state = event.resumo;
          } else if (event is SearchEvent) {
            debugPrint('SearchEvent: ${event.precedents.length} precedentes');
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
    final resumo = ref.watch(resumoProvider);

    final hasSSEData = precedentsMap.isNotEmpty;

    final isSSELoading =
        peticaoId != null &&
        precedentsMap.isEmpty &&
        !state.isSuggestionsLoading;

    // Resumo: usa SSE se disponível, senão tenta do banco
    final resumoTexto = resumo ?? state.petitionSummary;
    final isResumoLoading =
        peticaoId != null && resumo == null && state.petitionSummary == null;

    final visibleSSEPrecedents = precedentsMap.values
        .take(state.selectedLimit)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnalysisSectionTitle(
                title: 'Analisando Arquivo',
                textTheme: textTheme,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.isFileLoading)
            const AnalysisFileSkeleton()
          else
            _buildFileCard(state.documentDisplayName, textTheme),
          const SizedBox(height: 28),

          // Seção de resumo — skeleton enquanto aguarda, card quando chegar
          AnalysisSectionTitle(
            title: 'Síntese da Petição',
            textTheme: textTheme,
          ),
          const SizedBox(height: 12),
          if (isResumoLoading)
            const PetitionSummarySkeleton()
          else if (resumoTexto != null && resumoTexto.isNotEmpty)
            _buildSummaryCard(resumoTexto, textTheme)
          else
            const PetitionSummarySkeleton(),
          const SizedBox(height: 28),

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
            const SuggestionCardsSkeleton()
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
              onTap: () => BottomSheetPrecedentSuggested.showSSE(
                context,
                precedents[index],
                synthesisMap[precedents[index].id],
              ),
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
              onTap: () => BottomSheetPrecedentSuggested.show(
                context,
                suggestions[index],
              ),
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
