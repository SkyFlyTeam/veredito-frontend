import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../petition/domain/entities/peticao.dart';
import '../../../data/models/pipeline_event_model.dart';
import '../providers/pipeline_stream_provider.dart';
import '../view_models/analysis_precedent_view_model.dart';
import '../widget/PrecedentSuggestedCard.dart';
import '../widget/bottom_sheet_precedent_suggested.dart';
import '../widget/analysis_file_skeleton.dart';
import '../widget/sentence_modal.dart';
import '../widget/analysis_section_title.dart';
import '../widget/petition_summary_skeleton.dart';
import '../widget/suggestion_cards_skeleton.dart';
import '../widget/suggestion_limit_dropdown.dart';
import '../view_models/analysis_precedent_state.dart';
import '../providers/analysis_precedent_view_model_provider.dart';


class AnalysisPrecedentScreen extends ConsumerStatefulWidget {
  final Peticao? petition;

  const AnalysisPrecedentScreen({super.key, this.petition});

  @override
  ConsumerState<AnalysisPrecedentScreen> createState() =>
      _AnalysisPrecedentScreenState();
}

class _AnalysisPrecedentScreenState
    extends ConsumerState<AnalysisPrecedentScreen>
    with RouteAware {
  late final AnalysisPrecedentState _initialState;
  ProviderSubscription<AsyncValue<PipelineEvent>>? _streamSubscription;
  VoidCallback? _cancelStreamConnection;

  @override
  void initState() {
    super.initState();
    _initialState = AnalysisPrecedentState.initial(petition: widget.petition);

    final petition = widget.petition;
    if (petition != null && petition.id > 0) {
      _cancelStreamConnection = ref.read(
        pipelineStreamCancelProvider(petition.id),
      );
      _streamSubscription = ref.listenManual(
        pipelineStreamProvider(petition.id),
        (previous, next) {
          next.when(
            data: (event) {
              _handleStreamEvent(
                event,
                ref.read(
                  analysisPrecedentViewModelProvider(_initialState).notifier,
                ),
                petition.id,
              );
            },
            error: (error, stack) {
              debugPrint('Pipeline stream error: $error');
              debugPrintStack(stackTrace: stack);
            },
            loading: () {},
          );
        },
      );
    }
  }

  @override
  void didPushNext() {
    _closeStreamSubscription();
  }

  @override
  void didPop() {
    _closeStreamSubscription();
  }

  @override
  void didPopNext() {
    final petition = widget.petition;
    if (petition != null && petition.id > 0 && _streamSubscription == null) {
      _streamSubscription = ref.listenManual(
        pipelineStreamProvider(petition.id),
        (previous, next) {
          next.when(
            data: (event) {
              _handleStreamEvent(
                event,
                ref.read(
                  analysisPrecedentViewModelProvider(_initialState).notifier,
                ),
                petition.id,
              );
            },
            error: (error, stack) {
              debugPrint('Pipeline stream error: $error');
              debugPrintStack(stackTrace: stack);
            },
            loading: () {},
          );
        },
      );
    }
  }

  void _closeStreamSubscription() {
    debugPrint('Analysis: Stream subscription closed');
    _cancelStreamConnection?.call();
    _cancelStreamConnection = null;
    _streamSubscription?.close();
    _streamSubscription = null;
  }

  @override
  void dispose() {
    _closeStreamSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const suggestionLimitOptions = [1, 5, 10];
    final state = ref.watch(analysisPrecedentViewModelProvider(_initialState));
    final viewModel = ref.read(
      analysisPrecedentViewModelProvider(_initialState).notifier,
    );

    return Stack(
      children: [
        SingleChildScrollView(
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
            _buildFileCard(state, textTheme),
          const SizedBox(height: 28),
          AnalysisSectionTitle(
            title: 'Síntese da Petição',
            textTheme: textTheme,
          ),
          const SizedBox(height: 12),
          if (state.isSummaryLoading) ...[
            const PetitionSummarySkeleton(),
          ] else if (state.petitionSummary != null) ...[
            _buildSummaryCard(state, textTheme),
          ],
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
                  if (value == null) {
                    return;
                  }
                  viewModel.setSelectedLimit(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.isSuggestionsLoading)
            const SuggestionCardsSkeleton()
          else if (state.visibleSuggestions.isEmpty)
            _buildEmptyPrecedentListState(textTheme)
          else
            _buildSuggestionCard(state, textTheme, context),
          const SizedBox(height: 80),
        ],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: FloatingActionButton.extended(
            heroTag: 'sentence_modal_fab',
            onPressed: state.visibleSuggestions.isEmpty
                ? null
                : () => SentenceModal.show(
                      context,
                      suggestions: state.visibleSuggestions,
                    ),
            backgroundColor: state.visibleSuggestions.isEmpty
                ? AppColors.purple200.withValues(alpha: 0.4)
                : AppColors.purple200,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.description_outlined, size: 18),
            label: const Text(
              'Gerar Minuta',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }


  /// Handles incoming stream events and updates the view model state
  void _handleStreamEvent(
    PipelineEvent event,
    AnalysisPrecedentViewModel viewModel,
    int peticaoId,
  ) {
    debugPrint('Analysis: Received stream event: ${event.stage}');

    switch (event) {
      case ResumoEvent resumoEvent:
        viewModel.handleResumoEvent(resumoEvent);
        break;
      case SearchEvent searchEvent:
        viewModel.handleSearchEvent(searchEvent, peticaoId);
        break;
      case SynthesisEvent synthesisEvent:
        viewModel.handleSynthesisEvent(synthesisEvent);
        break;
      case ErrorEvent errorEvent:
        viewModel.handleErrorEvent(errorEvent);
        break;
      default:
        debugPrint(
          'Analysis: Received unknown event type: ${event.runtimeType}',
        );
    }
  }
}

Widget _buildFileCard(AnalysisPrecedentState state, TextTheme textTheme) {
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
              state.documentDisplayName,
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

Widget _buildSummaryCard(AnalysisPrecedentState state, TextTheme textTheme) {
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
          letterSpacing: 0,
        ),
      ),
    ),
  );
}

Widget _buildEmptyPrecedentListState(TextTheme textTheme) {
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

Widget _buildSuggestionCard(
  AnalysisPrecedentState state,
  TextTheme textTheme,
  context,
) {
  return Column(
    children: [
      for (var index = 0; index < state.visibleSuggestions.length; index++)
        Padding(
          padding: EdgeInsets.only(
            bottom: index == state.visibleSuggestions.length - 1 ? 0 : 12,
          ),
          child: GestureDetector(
            onTap: () => BottomSheetPrecedentSuggested.show(
              context,
              state.visibleSuggestions[index],
              isClassificationLoading:
                  !state.visibleSuggestions[index].hasSinteseExplicativa,
              isSinteseLoading:
                  !state.visibleSuggestions[index].hasSinteseExplicativa,
            ),
            child: PrecedentSuggestedCard(
              suggestedPrecedent: state.visibleSuggestions[index],
              isClassificationLoading:
                  !state.visibleSuggestions[index].hasSinteseExplicativa,
            ),
          ),
        ),
    ],
  );
}
