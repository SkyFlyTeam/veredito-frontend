import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../petition/domain/entities/peticao.dart';
import '../../../domain/entities/precedent_stream_events/complete_event.dart';
import '../../../domain/entities/precedent_stream_events/error_event.dart';
import '../../../domain/entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../../../domain/entities/precedent_stream_events/resumo_event.dart';
import '../../../domain/entities/precedent_stream_events/search_event.dart';
import '../../../domain/entities/precedent_stream_events/synthesis_event.dart';
import '../providers/analysis_petition_providers.dart';
import '../view_models/analysis_petition_state.dart';
import '../view_models/analysis_petition_view_model.dart';
import '../widgets/analysis_file_skeleton.dart';
import '../widgets/analysis_section_title.dart';
import '../widgets/bottom_sheet_precedent_suggested.dart';
import '../widgets/petition_summary_skeleton.dart';
import '../widgets/precedent_suggested_card.dart';
import '../widgets/suggestion_cards_skeleton.dart';
import '../widgets/suggestion_limit_dropdown.dart';

class AnalyzePetitionScreen extends ConsumerStatefulWidget {
	final Peticao? petition;

	const AnalyzePetitionScreen({super.key, this.petition});

	@override
	ConsumerState<AnalyzePetitionScreen> createState() =>
			_AnalyzePetitionScreenState();
}

class _AnalyzePetitionScreenState extends ConsumerState<AnalyzePetitionScreen>
		with RouteAware {
	late final AnalysisPetitionState _initialState;
	ProviderSubscription<AsyncValue<PrecedentStreamPipelineEvent>>?
			_streamSubscription;
	VoidCallback? _cancelStreamConnection;

	@override
	void initState() {
		super.initState();
		_initialState = AnalysisPetitionState.initial(petition: widget.petition);

		final petition = widget.petition;
		if (petition != null && petition.id > 0) {
			_cancelStreamConnection = ref.read(
				petitionPipelineCancelProvider(petition.id),
			);
			_streamSubscription = ref.listenManual(
				petitionPipelineStreamProvider(petition.id),
				(previous, next) {
					next.when(
						data: (event) {
							_handleStreamEvent(
								event,
								ref
										.read(analysisPetitionViewModelProvider(_initialState)
												.notifier),
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
				petitionPipelineStreamProvider(petition.id),
				(previous, next) {
					next.when(
						data: (event) {
							_handleStreamEvent(
								event,
								ref
										.read(analysisPetitionViewModelProvider(_initialState)
												.notifier),
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
		debugPrint('AnalyzePetition: Stream subscription closed');
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
		final state = ref.watch(analysisPetitionViewModelProvider(_initialState));
		final viewModel = ref.read(
			analysisPetitionViewModelProvider(_initialState).notifier,
		);

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
						_buildSuggestionCard(state, context),
				],
			),
		);
	}

	/// Handles incoming stream events and updates the view model state
	void _handleStreamEvent(
		PrecedentStreamPipelineEvent event,
		AnalysisPetitionViewModel viewModel,
	) {
		debugPrint('AnalyzePetition: Received stream event: ${event.stage}');

		switch (event) {
			case ResumoEvent resumoEvent:
				viewModel.handleResumoEvent(resumoEvent);
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
					'AnalyzePetition: complete, total_duration_ms=${completeEvent.totalDurationMs}, precedents_processed=${completeEvent.precedentsProcessed}, synthesis_generated=${completeEvent.synthesisGenerated}',
				);
				break;
			default:
				debugPrint(
					'AnalyzePetition: Received unknown event type: ${event.runtimeType}',
				);
		}
	}
}

Widget _buildFileCard(AnalysisPetitionState state, TextTheme textTheme) {
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

Widget _buildSummaryCard(AnalysisPetitionState state, TextTheme textTheme) {
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
	AnalysisPetitionState state,
	BuildContext context,
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
