import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/file_saver.dart';
import '../../../../../core/utils/notification_service.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../analysis/domain/entities/legal_case_stream_events/secoes_event.dart';
import '../../../../analysis/domain/entities/precedent_stream_events/complete_event.dart';
import '../../../../analysis/domain/entities/precedent_stream_events/error_event.dart';
import '../../../../analysis/domain/entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../../../../analysis/domain/entities/precedent_stream_events/search_event.dart';
import '../../../../analysis/domain/entities/precedent_stream_events/synthesis_event.dart';
import '../../../../analysis/domain/entities/secao_peticao.dart';
import '../../../../analysis/presentation/legal_case/widgets/section_card.dart';
import '../../../../analysis/domain/entities/precedent_suggested.dart';
import '../../../domain/entities/legal_case.dart';
import '../../shared/widgets/analysis_section_title.dart';
import '../../shared/widgets/precedent_suggestions/animated_skeleton_block.dart';
import '../../shared/widgets/precedent_suggestions/bottom_sheet_precedent_suggested.dart';
import '../../shared/widgets/precedent_suggestions/precedent_suggested_card.dart';
import '../../shared/widgets/precedent_suggestions/suggestion_cards_skeleton.dart';
import '../../shared/widgets/precedent_suggestions/suggestion_limit_dropdown.dart';
import '../providers/minuta_peticao_providers.dart';
import '../view_models/minuta_peticao_state.dart';
import '../view_models/minuta_peticao_view_model.dart';


class MinutaPeticaoScreen extends ConsumerStatefulWidget {
  final LegalCase legalCase;

  const MinutaPeticaoScreen({super.key, required this.legalCase});

  @override
  ConsumerState<MinutaPeticaoScreen> createState() =>
      _MinutaPeticaoScreenState();
}

class _MinutaPeticaoScreenState extends ConsumerState<MinutaPeticaoScreen>
  with RouteAware {
  late final MinutaPeticaoState _initialState;
  ProviderSubscription<AsyncValue<PrecedentStreamPipelineEvent>>?
      _streamSubscription;
  VoidCallback? _cancelStreamConnection;
  late final LegalCasePipelineParams _streamParams;

  @override
  void initState() {
    super.initState();
    _initialState = MinutaPeticaoState.initial(widget.legalCase);
    _streamParams =
        LegalCasePipelineParams(legalCaseId: widget.legalCase.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(minutaPeticaoViewModelProvider(_initialState).notifier)
          .initialize();
    });

    if (widget.legalCase.id > 0) {
      _cancelStreamConnection = ref.read(
        legalCasePipelineCancelProvider(widget.legalCase.id),
      );
      _streamSubscription = ref.listenManual(
        legalCasePipelineStreamProvider(_streamParams),
        (previous, next) {
          next.when(
            data: (event) {
              _handleStreamEvent(
                event,
                ref
                    .read(minutaPeticaoViewModelProvider(_initialState).notifier),
              );
            },
            error: (error, stack) {
              debugPrint('MinutaPeticao: stream error: $error');
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
    if (widget.legalCase.id > 0 && _streamSubscription == null) {
      _streamSubscription = ref.listenManual(
        legalCasePipelineStreamProvider(_streamParams),
        (previous, next) {
          next.when(
            data: (event) {
              _handleStreamEvent(
                event,
                ref
                    .read(minutaPeticaoViewModelProvider(_initialState).notifier),
              );
            },
            error: (error, stack) {
              debugPrint('MinutaPeticao: stream error: $error');
              debugPrintStack(stackTrace: stack);
            },
            loading: () {},
          );
        },
      );
    }
  }

  void _closeStreamSubscription() {
    debugPrint('MinutaPeticao: stream subscription closed');
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
    final state = ref.watch(minutaPeticaoViewModelProvider(_initialState));
    final viewModel = ref.read(
      minutaPeticaoViewModelProvider(_initialState).notifier,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.purple200,
        onPressed: state.isDownloadingPeticao
            ? null
            : () => _handlePeticaoDownload(context, viewModel),
        child: state.isDownloadingPeticao
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.ios_share_rounded, color: Colors.white),
      ),
      body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (state.isMinutaLoading)
                const _SectionsSkeleton()
              else if (state.errorMessage != null)
                _ErrorCard(message: state.errorMessage!)
              else if (state.secoes == null || state.secoes!.isEmpty)
                _EmptyCard(textTheme: textTheme)
              else
                _SectionsList(
                  secoes: state.secoes!,
                  onEdit: (secao) => unawaited(viewModel.updateSecao(secao)),
                ),

              const SizedBox(height: 28),

              // ── Precedentes Sugeridos ─────────────────────────────────────
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
                    options: const [1, 5, 10],
                    onChanged: (value) {
                      if (value == null) return;
                      viewModel.setSelectedLimit(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (state.isSuggestionsLoading)
                const SuggestionCardsSkeleton()
              else if (state.visiblePrecedentes.isEmpty)
                _EmptyCard(textTheme: textTheme)
              else
                _PrecedentesList(precedentes: state.visiblePrecedentes),

              const SizedBox(height: 20),
            ],
          ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'Minuta De Petição',
        style: GoogleFonts.montserrat(
          color: AppColors.gray100,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _handleStreamEvent(
    PrecedentStreamPipelineEvent event,
    MinutaPeticaoViewModel viewModel,
  ) {
    debugPrint('MinutaPeticao: Received stream event: ${event.stage}');

    switch (event) {
      case SecoesEvent secoesEvent:
        viewModel.handleSecoesEvent(secoesEvent);
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
          'MinutaPeticao: complete, total_duration_ms=${completeEvent.totalDurationMs}, precedents_processed=${completeEvent.precedentsProcessed}, synthesis_generated=${completeEvent.synthesisGenerated}',
        );
        viewModel.handleCompleteEvent();
        break;
      default:
        debugPrint(
          'MinutaPeticao: Received unknown event type: ${event.runtimeType}',
        );
    }
  }

  Future<void> _handlePeticaoDownload(
    BuildContext context,
    MinutaPeticaoViewModel viewModel,
  ) async {
    final legalCaseId = widget.legalCase.id;
    if (legalCaseId <= 0) {
      return;
    }

    final bytes = await viewModel.downloadPeticaoBytes();
    if (bytes == null) {
      if (!mounted) return;
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: const Text('Erro'),
        description: const Text('Nao foi possivel baixar a peticao.'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
      return;
    }

    final fileName =
        'minuta_peticao_${legalCaseId}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    try {
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
        title: const Text('Sucesso'),
        description: const Text('Peticao salva em Downloads.'),
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
        title: const Text('Erro'),
        description: const Text('Nao foi possivel salvar a peticao.'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionsList extends StatelessWidget {
  final List<SecaoPeticao> secoes;
  final void Function(SecaoPeticao) onEdit;

  const _SectionsList({required this.secoes, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < secoes.length; i++) ...[
          SectionCard(secao: secoes[i], onEdit: onEdit),
          if (i < secoes.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _PrecedentesList extends StatelessWidget {
  final List<PrecedentSuggested> precedentes;

  const _PrecedentesList({required this.precedentes});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < precedentes.length; i++) ...[
          GestureDetector(
            onTap: () => BottomSheetPrecedentSuggested.show(
              context,
              precedentes[i],
              isClassificationLoading: !precedentes[i].hasSinteseExplicativa,
              isSinteseLoading: !precedentes[i].hasSinteseExplicativa,
            ),
            child: PrecedentSuggestedCard(
              suggestedPrecedent: precedentes[i],
              isClassificationLoading: !precedentes[i].hasSinteseExplicativa,
            ),
          ),
          if (i < precedentes.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SectionsSkeleton extends StatelessWidget {
  const _SectionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (i) => _SkeletonCard(index: i)),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final int index;

  const _SkeletonCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: index < 2 ? 16 : 0),
      child: GlassCard(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSkeletonBlock(width: 140, height: 14, borderRadius: 7),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gray100.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSkeletonBlock(
                        width: double.infinity, height: 11, borderRadius: 5),
                    const SizedBox(height: 8),
                    AnimatedSkeletonBlock(
                        width: double.infinity, height: 11, borderRadius: 5),
                    const SizedBox(height: 8),
                    AnimatedSkeletonBlock(
                        width: 200, height: 11, borderRadius: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.red300, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.red300,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final TextTheme textTheme;

  const _EmptyCard({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Text(
          'Nenhum resultado gerado para esta petição.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.gray100,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}