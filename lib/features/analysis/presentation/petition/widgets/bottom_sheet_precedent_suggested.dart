import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/precedent_suggested.dart';
import 'animated_skeleton_block.dart';
import 'precedent_classification_badge.dart';

class BottomSheetPrecedentSuggested extends StatefulWidget {
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

  @override
  State<BottomSheetPrecedentSuggested> createState() =>
      _BottomSheetPrecedentSuggestedState();
}

class _BottomSheetPrecedentSuggestedState
    extends State<BottomSheetPrecedentSuggested> {
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
                        onOpenPangeaUrl:
                            _pangeaUrl != null ? _openPangeaUrl : null,
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
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BottomSheetHeader(
            title: title,
            tribunalSigla: tribunalSigla,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.blue50,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                dataAtualizacao,
                maxLines: 1,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.gray100,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.purple200.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.gray100.withValues(alpha: 0.7),
                width: 0.7,
              ),
            ),
            child: Text(
              thesis,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.gray100,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 5,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PrecedentClassificationBadge(
                    label: classification,
                    backgroundColor: classificationColor,
                    isLoading: isClassificationLoading,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 4,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'similaridade de',
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.gray100,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        similarity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _BottomSheetSintese(
            textTheme: textTheme,
            shouldShowSinteseLoading: shouldShowSinteseLoading,
            sintese: sintese,
          ),
          if (pangeaUrl != null) ...[
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onOpenPangeaUrl,
                child: Text(
                  'Ver no Pangea',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.purple100,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomSheetHeader extends StatelessWidget {
  final String title;
  final String tribunalSigla;

  const _BottomSheetHeader({
    required this.title,
    required this.tribunalSigla,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.gray100,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.purple200,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            tribunalSigla,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _BottomSheetSintese extends StatelessWidget {
  final TextTheme textTheme;
  final bool shouldShowSinteseLoading;
  final String? sintese;

  const _BottomSheetSintese({
    required this.textTheme,
    required this.shouldShowSinteseLoading,
    required this.sintese,
  });

  @override
  Widget build(BuildContext context) {
    if (shouldShowSinteseLoading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sintese explicativa',
            style: TextStyle(
              color: AppColors.gray100,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          AnimatedSkeletonBlock(height: 12, borderRadius: 8),
          SizedBox(height: 8),
          AnimatedSkeletonBlock(height: 12, borderRadius: 8),
          SizedBox(height: 8),
          FractionallySizedBox(
            widthFactor: 0.62,
            child: AnimatedSkeletonBlock(height: 12, borderRadius: 8),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sintese explicativa',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.gray100,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sintese ?? 'Sem sintese explicativa disponivel.',
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.gray100,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
