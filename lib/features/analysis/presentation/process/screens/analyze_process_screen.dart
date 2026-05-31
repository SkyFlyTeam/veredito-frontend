import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/file_saver.dart';
import '../../../../../core/utils/notification_service.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/bottom_sheet.dart';
import '../../../../../routes/app_router.dart';
import '../../../domain/entities/especie_precedente.dart';
import '../../../domain/entities/precedent_stream_events/complete_event.dart';
import '../../../domain/entities/precedent_stream_events/error_event.dart';
import '../../../domain/entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../../../domain/entities/precedent_stream_events/search_event.dart';
import '../../../domain/entities/precedent_stream_events/synthesis_event.dart';
import '../../../domain/entities/precedent_suggested.dart';
import '../../../domain/entities/process_stream_events/general_info_event.dart';
import '../../../domain/entities/process_stream_events/pecas_event.dart';
import '../../../domain/entities/processo_juridico.dart';
import '../../../domain/entities/tribunal_precedente.dart';
import '../../shared/widgets/analysis_file_skeleton.dart';
import '../../shared/widgets/analysis_section_title.dart';
import '../../shared/widgets/precedent_suggestions/animated_skeleton_block.dart';
import '../../shared/widgets/precedent_suggestions/bottom_sheet_precedent_suggested.dart';
import '../../shared/widgets/precedent_suggestions/precedent_suggested_card.dart';
import '../../shared/widgets/precedent_suggestions/suggestion_cards_skeleton.dart';
import '../../shared/widgets/precedent_suggestions/suggestion_limit_dropdown.dart';
import '../providers/analysis_process_providers.dart';
import '../view_models/analysis_process_state.dart';
import '../view_models/analysis_process_view_model.dart';
import '../widgets/card_section.dart';
import '../widgets/sentence_modal.dart';
import '../providers/new_process_analysis_providers.dart';

class AnalyzeProcessScreen extends ConsumerStatefulWidget {
  final ProcessoJuridico processo;
  final List<TribunalPrecedente> tribunaisPrecedentes;
  final List<EspeciePrecedente> especiesPrecedentes;

  const AnalyzeProcessScreen({
    super.key,
    required this.processo,
    required this.tribunaisPrecedentes,
    required this.especiesPrecedentes,
  });

  @override
  ConsumerState<AnalyzeProcessScreen> createState() =>
      _AnalyzeProcessScreenState();
}

class _AnalyzeProcessScreenState extends ConsumerState<AnalyzeProcessScreen>
    with RouteAware {
  late final AnalysisProcessState _initialState;
  ProviderSubscription<AsyncValue<PrecedentStreamPipelineEvent>>?
  _streamSubscription;
  VoidCallback? _cancelStreamConnection;
  late final ProcessPipelineParams _streamParams;

  @override
  void initState() {
    super.initState();
    _initialState = AnalysisProcessState.initial(processo: widget.processo);
    _streamParams = ProcessPipelineParams(
      processoId: widget.processo.id ?? 0,
      tribunais: widget.tribunaisPrecedentes,
      especies: widget.especiesPrecedentes,
    );

    final processoId = widget.processo.id ?? 0;
    if (processoId > 0) {
      _cancelStreamConnection = ref.read(
        processPipelineCancelProvider(processoId),
      );
      _streamSubscription = ref.listenManual(
        processPipelineStreamProvider(_streamParams),
        (previous, next) {
          next.when(
            data: (event) {
              _handleStreamEvent(
                event,
                ref.read(
                  analysisProcessViewModelProvider(_initialState).notifier,
                ),
              );
            },
            error: (error, stack) {
              debugPrint('Process pipeline stream error: $error');
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
    final processoId = widget.processo.id ?? 0;
    if (processoId > 0 && _streamSubscription == null) {
      _streamSubscription = ref.listenManual(
        processPipelineStreamProvider(_streamParams),
        (previous, next) {
          next.when(
            data: (event) {
              _handleStreamEvent(
                event,
                ref.read(
                  analysisProcessViewModelProvider(_initialState).notifier,
                ),
              );
            },
            error: (error, stack) {
              debugPrint('Process pipeline stream error: $error');
              debugPrintStack(stackTrace: stack);
            },
            loading: () {},
          );
        },
      );
    }
  }

  void _closeStreamSubscription() {
    debugPrint('AnalyzeProcess: Stream subscription closed');
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
    final state = ref.watch(analysisProcessViewModelProvider(_initialState));
    final viewModel = ref.read(
      analysisProcessViewModelProvider(_initialState).notifier,
    );

		return Stack(
			children: [
				SingleChildScrollView(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
						AnalysisSectionTitle(
							title: 'Analisando Processo',
							textTheme: textTheme,
						),
						const SizedBox(height: 12),
						if (state.isFileLoading)
							const AnalysisFileSkeleton()
						else
							_buildFileCard(state, textTheme),
						const SizedBox(height: 28),
						AnalysisSectionTitle(
							title: 'Informacoes gerais',
							textTheme: textTheme,
						),
						const SizedBox(height: 12),
						if (state.isGeneralInfoLoading)
							_buildCardSectionSkeleton(count: 3)
						else if (!state.hasGeneralInfoData)
							_buildEmptyInfoState(textTheme)
						else
							_buildGeneralInfoCards(context, state),
						const SizedBox(height: 28),
						AnalysisSectionTitle(
							title: 'Pecas classificadas',
							textTheme: textTheme,
						),
						const SizedBox(height: 12),
						if (state.isPiecesLoading)
							_buildCardSectionSkeleton(count: 3)
						else if (state.classifiedPieces.isEmpty)
							_buildEmptyPiecesState(textTheme)
						else
							_buildPiecesCards(context, state),
						const SizedBox(height: 28),
						Row(
							crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								Expanded(
									child: AnalysisSectionTitle(
										title: 'Precedentes sugeridos',
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
							_buildSuggestionCard(state, context),
						const SizedBox(height: 80),
					],
				),
			),
				Positioned(
					bottom: 16,
					right: 16,
					child: FloatingActionButton(
						onPressed: () => SentenceModal.show(
							context,
							suggestions: state.suggestions ?? const [],
							onSave: (text, selectedSuggestions) =>
								_handleSentenceSave(text, selectedSuggestions),
						),
						backgroundColor: AppColors.purple200,
						foregroundColor: AppColors.gray100,
						elevation: 4,
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(15),
						),
						child: const Icon(Icons.gavel_rounded, size: 21),
					),
				),
			],
		);
	}

	Future<void> _handleSentenceSave(
		String text,
		List<PrecedentSuggested> selectedSuggestions,
	) async {
		final processoId = widget.processo.id ?? 0;
		if (processoId <= 0) {
			return;
		}

		final selectedIds =
				selectedSuggestions.map((p) => p.precedentId).toList();
		final useCase = ref.read(processUseCaseProvider);

		try {
			final bytes = await useCase.generateMinutaSentenca(
				processoId: processoId,
				dispositivo: text,
				precedentesSugeridos: selectedIds,
			);

			final fileName =
					'minuta_sentenca_${processoId}_${DateTime.now().millisecondsSinceEpoch}.docx';
			final savedFile = await FileSaver().saveBytesToDownloads(
				bytes: bytes,
				fileName: fileName,
			);
			await NotificationService.instance.showDownloadNotification(
				filePath: savedFile.path,
				fileName: fileName,
			);

			if (!mounted) return;
			toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: const Text("Sucesso"),
          description: const Text("Minuta de sentença gerada e salva em Downloads."),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
		} catch (_) {
			if (!mounted) return;
			toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: const Text("Erro"),
          description: const Text("Não foi possivel gerar a minuta no momento."),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
		}
	}

	void _handleStreamEvent(
		PrecedentStreamPipelineEvent event,
		AnalysisProcessViewModel viewModel,
	) {
		debugPrint('AnalyzeProcess: Received stream event: ${event.stage}');

    switch (event) {
      case GeneralInfoEvent generalInfoEvent:
        viewModel.handleGeneralInfoEvent(generalInfoEvent);
        break;
      case PecasEvent pecasEvent:
        viewModel.handlePecasEvent(pecasEvent);
        break;
      case SearchEvent searchEvent:
        viewModel.handleSearchEvent(searchEvent);
        break;
      case SynthesisEvent synthesisEvent:
        viewModel.handleSynthesisEvent(synthesisEvent);
        break;
      case ErrorEvent errorEvent:
        viewModel.handleErrorEvent(errorEvent);
        break;
      case CompleteEvent completeEvent:
        debugPrint(
          'AnalyzeProcess: complete, total_duration_ms=${completeEvent.totalDurationMs}, precedents_processed=${completeEvent.precedentsProcessed}, synthesis_generated=${completeEvent.synthesisGenerated}',
        );
        break;
      default:
        debugPrint(
          'AnalyzeProcess: Received unknown event type: ${event.runtimeType}',
        );
    }
  }
}

Widget _buildFileCard(AnalysisProcessState state, TextTheme textTheme) {
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

Widget _buildGeneralInfoCards(
  BuildContext context,
  AnalysisProcessState state,
) {
  return Column(
    children: [
      CardSection(
        title: 'Fatos',
        icon: Icons.subject_outlined,
        onClick: () => _showInfoBottomSheet(
          context,
          title: 'Fatos',
          content: _resolveInfoContent(state.fatos),
        ),
      ),
      const SizedBox(height: 12),
      CardSection(
        title: 'Pedidos',
        icon: Icons.description_outlined,
        onClick: () => _showInfoBottomSheet(
          context,
          title: 'Pedidos',
          content: _resolveInfoContent(state.pedidos),
        ),
      ),
      const SizedBox(height: 12),
      CardSection(
        title: 'Fundamentos juridicos',
        icon: Icons.balance_outlined,
        onClick: () => _showInfoBottomSheet(
          context,
          title: 'Fundamentos juridicos',
          content: _resolveInfoContent(state.fundamentosJuridicos),
        ),
      ),
    ],
  );
}

Widget _buildPiecesCards(BuildContext context, AnalysisProcessState state) {
  return Column(
    children: [
      for (var index = 0; index < state.classifiedPieces.length; index++)
        Padding(
          padding: EdgeInsets.only(
            bottom: index == state.classifiedPieces.length - 1 ? 0 : 12,
          ),
          child: CardSection(
            title: state.classifiedPieces[index].nome,
            icon: Icons.insert_drive_file_outlined,
            onClick: () => Navigator.of(context).pushNamed(
              AppRouter.processPecaViewer,
              // VER-122: o viewer abre o PDF do processo na página da peça.
              arguments: {
                'peca': state.classifiedPieces[index],
                'processoId': state.processo?.id ?? 0,
              },
            ),
          ),
        ),
    ],
  );
}

Widget _buildEmptyInfoState(TextTheme textTheme) {
  return GlassCard(
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Text(
        'Nenhuma informacao geral disponivel no momento.',
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

Widget _buildEmptyPiecesState(TextTheme textTheme) {
  return GlassCard(
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Text(
        'Nenhuma peca classificada no momento.',
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

Widget _buildCardSectionSkeleton({required int count}) {
  return Column(
    children: [
      for (var index = 0; index < count; index++)
        Padding(
          padding: EdgeInsets.only(bottom: index == count - 1 ? 0 : 12),
          child: GlassCard(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Row(
                children: const [
                  AnimatedSkeletonBlock(width: 22, height: 22, borderRadius: 6),
                  SizedBox(width: 12),
                  Expanded(
                    child: AnimatedSkeletonBlock(height: 14, borderRadius: 6),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
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

Widget _buildSuggestionCard(AnalysisProcessState state, BuildContext context) {
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

String _resolveInfoContent(String? content) {
  final resolved = content?.trim() ?? '';
  if (resolved.isEmpty) {
    return 'Sem informacoes disponiveis.';
  }
  return resolved;
}

void _showInfoBottomSheet(
  BuildContext context, {
  required String title,
  required String content,
}) {
  AppBottomSheet.show<void>(
    context,
    showScrollbar: true,
    bodyBuilder: (context) =>
        _InfoBottomSheetBody(title: title, content: content),
  );
}

class _InfoBottomSheetBody extends StatelessWidget {
  final String title;
  final String content;

  const _InfoBottomSheetBody({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.gray100,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.gray100,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
