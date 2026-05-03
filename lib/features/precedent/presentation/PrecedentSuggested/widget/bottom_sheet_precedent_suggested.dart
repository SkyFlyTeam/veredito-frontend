import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/text_formater.dart';
import '../../../data/models/pipeline_event_model.dart';
import '../../../domain/entities/precedent.dart';
import '../../../domain/entities/precedent_suggested.dart';
import 'animated_skeleton_block.dart';
import 'precedent_classification_badge.dart';

class BottomSheetPrecedentSuggested extends ConsumerStatefulWidget {
  final PrecedentSuggested suggestedPrecedent;
  final bool isClassificationLoading;
  final bool? isSinteseLoading;

  const BottomSheetPrecedentSuggested({
    super.key,
    required this.suggestedPrecedent,
    this.isClassificationLoading = false,
    this.isSinteseLoading,
  });

  static void show(
    BuildContext context,
    PrecedentSuggested suggestedPrecedent, {
    bool? isClassificationLoading,
    bool? isSinteseLoading,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BottomSheetPrecedentSuggested(
        suggestedPrecedent: suggestedPrecedent,
        isClassificationLoading: isClassificationLoading ?? false,
        isSinteseLoading: isSinteseLoading,
      ),
    );
  }

  static void showSSE(
    BuildContext context,
    PrecedentBackendDto precedent,
    SynthesisEvent? synthesis,
  ) {
    // Cria um Precedent a partir dos dados SSE
    final precedentEntity = Precedent(
      id: precedent.id,
      numeroRegistro: precedent.numeroRegistro,
      tese: precedent.tese ?? precedent.questao,
      ultimaAtualizacao: null,
      teseVetor: null,
      questaoVetor: null,
      tribunalNome: precedent.tribunalNome,
      tribunalSigla: precedent.tribunalSigla,
      statusNome: precedent.statusNome,
      especieNome: precedent.especieNome,
      especieSigla: precedent.especieSigla,
    );

    // Cria um PrecedentSuggested com o Precedent
    final suggested = PrecedentSuggested(
      id: precedent.id,
      petitionId: 0,
      precedentId: precedent.id,
      percentualSimilaridade:
          synthesis?.percentual_similaridade ??
          precedent.percentualSimilaridade,
      classificacao: synthesis?.classificacao ?? 0,
      sinteseExplicativa: synthesis?.sintese_explicativa,
      precedent: precedentEntity,
    );

    show(context, suggested, isSinteseLoading: synthesis == null);
  }

  @override
  ConsumerState<BottomSheetPrecedentSuggested> createState() =>
      _BottomSheetPrecedentSuggestedState();
}

class _BottomSheetPrecedentSuggestedState
    extends ConsumerState<BottomSheetPrecedentSuggested> {
  final GlobalKey _bodyMeasureKey = GlobalKey();

  bool _isLoadingSintese = false;
  String? _sintese;
  double? _bodyHeight;

  String? get _pangeaUrl => widget.suggestedPrecedent.pangeaUrl;

  @override
  void initState() {
    super.initState();
    if (widget.isSinteseLoading != null) {
      _isLoadingSintese = widget.isSinteseLoading!;
      if (widget.suggestedPrecedent.hasSinteseExplicativa) {
        _sintese = widget.suggestedPrecedent.sinteseExplicativa;
      }
    } else if (widget.suggestedPrecedent.hasSinteseExplicativa) {
      _sintese = widget.suggestedPrecedent.sinteseExplicativa;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _measureBodyHeight());
  }

  @override
  void didUpdateWidget(covariant BottomSheetPrecedentSuggested oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureBodyHeight());
  }

  void _measureBodyHeight() {
    if (!mounted) return;

    final renderObject = _bodyMeasureKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;

    final measuredHeight = renderObject.size.height;
    if (_bodyHeight == null || (_bodyHeight! - measuredHeight).abs() > 0.5) {
      setState(() {
        _bodyHeight = measuredHeight;
      });
    }
  }

  Future<void> _openPangeaUrl() async {
    final url = _pangeaUrl;
    if (url == null) return;

    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel abrir o link.')),
      );
    }
  }

  Color get _classificationColor {
    return widget.suggestedPrecedent.classificationColor;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight = screenHeight * 0.8;
    final shouldConstrainHeight =
        _bodyHeight == null || _bodyHeight! + 36 > maxSheetHeight;
    final title = widget.suggestedPrecedent.title;
    final tribunalSigla = widget.suggestedPrecedent.tribunalSigla;
    final status = widget.suggestedPrecedent.status;
    final dataAtualizacao = widget.suggestedPrecedent.dataAtualizacao;
    final thesis = widget.suggestedPrecedent.thesis;
    final classification = widget.suggestedPrecedent.classificationLabel;
    final similarity =
        widget.suggestedPrecedent.percentualSimilaridadePercentage;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final shouldShowSinteseLoading =
        widget.isSinteseLoading ?? _isLoadingSintese;

    return Stack(
      children: [
        Offstage(
          offstage: true,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: _BottomSheetPrecedentSuggestedBody(
                key: _bodyMeasureKey,
                textTheme: textTheme,
                title: title,
                tribunalSigla: tribunalSigla,
                status: status,
                dataAtualizacao: dataAtualizacao,
                thesis: thesis,
                classification: classification,
                similarity: similarity,
                pangeaUrl: _pangeaUrl,
                classificationColor: _classificationColor,
                isClassificationLoading: widget.isClassificationLoading,
                shouldShowSinteseLoading: shouldShowSinteseLoading,
                sintese: _sintese,
                bottomInset: bottomInset,
                onOpenPangeaUrl: _pangeaUrl != null ? _openPangeaUrl : null,
              ),
            ),
          ),
        ),
        if (shouldConstrainHeight)
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.blue800,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border(
                  top: BorderSide(color: AppColors.gray200, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BottomSheetHandle(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _BottomSheetPrecedentSuggestedBody(
                        textTheme: textTheme,
                        title: title,
                        tribunalSigla: tribunalSigla,
                        status: status,
                        dataAtualizacao: dataAtualizacao,
                        thesis: thesis,
                        classification: classification,
                        similarity: similarity,
                        pangeaUrl: _pangeaUrl,
                        classificationColor: _classificationColor,
                        isClassificationLoading: widget.isClassificationLoading,
                        shouldShowSinteseLoading: shouldShowSinteseLoading,
                        sintese: _sintese,
                        bottomInset: bottomInset,
                        onOpenPangeaUrl: _pangeaUrl != null
                            ? _openPangeaUrl
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.blue800,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(color: AppColors.gray200, width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BottomSheetHandle(),
                _BottomSheetPrecedentSuggestedBody(
                  textTheme: textTheme,
                  title: title,
                  tribunalSigla: tribunalSigla,
                  status: status,
                  dataAtualizacao: dataAtualizacao,
                  thesis: thesis,
                  classification: classification,
                  similarity: similarity,
                  pangeaUrl: _pangeaUrl,
                  classificationColor: _classificationColor,
                  isClassificationLoading: widget.isClassificationLoading,
                  shouldShowSinteseLoading: shouldShowSinteseLoading,
                  sintese: _sintese,
                  bottomInset: bottomInset,
                  onOpenPangeaUrl: _pangeaUrl != null ? _openPangeaUrl : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

class _BottomSheetPrecedentSuggestedBody extends StatelessWidget {
  final TextTheme textTheme;
  final String title;
  final String tribunalSigla;
  final String status;
  final String dataAtualizacao;
  final String thesis;
  final String classification;
  final String similarity;
  final String? pangeaUrl;
  final Color classificationColor;
  final bool isClassificationLoading;
  final bool shouldShowSinteseLoading;
  final String? sintese;
  final double bottomInset;
  final VoidCallback? onOpenPangeaUrl;

  const _BottomSheetPrecedentSuggestedBody({
    super.key,
    required this.textTheme,
    required this.title,
    required this.tribunalSigla,
    required this.status,
    required this.dataAtualizacao,
    required this.thesis,
    required this.classification,
    required this.similarity,
    required this.pangeaUrl,
    required this.classificationColor,
    required this.isClassificationLoading,
    required this.shouldShowSinteseLoading,
    required this.sintese,
    required this.bottomInset,
    required this.onOpenPangeaUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 15, 15, 30 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onOpenPangeaUrl,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.gray100,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 12,
                        color: pangeaUrl != null
                            ? AppColors.gray100
                            : AppColors.gray100.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 21,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.purple200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  tribunalSigla,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray100,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  capitalize(status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.blue50,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                dataAtualizacao,
                maxLines: 1,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.gray100,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Tese:',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.gray100,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.purple100.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.gray100, width: 0.5),
            ),
            child: Text(
              thesis,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.gray100,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.4,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PrecedentClassificationBadge(
                label: classification,
                backgroundColor: classificationColor,
                isLoading: isClassificationLoading,
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'similaridade de',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.gray100,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    similarity,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray100,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (shouldShowSinteseLoading)
            const _BottomSheetSinteseSkeleton()
          else if (sintese != null) ...[
            const SizedBox(height: 15),
            Text(
              'Síntese explicativa:',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.gray100,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.purple100.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: AppColors.gray100, width: 0.5),
              ),
              child: Text(
                sintese!,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.gray100,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomSheetSinteseSkeleton extends StatelessWidget {
  const _BottomSheetSinteseSkeleton();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(
          'Síntese explicativa:',
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.gray100,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSkeletonBlock(
          height: 52,
          borderRadius: 15,
          color: AppColors.purple100.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}
