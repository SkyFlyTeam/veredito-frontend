import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/text_formater.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../domain/entities/precedent_suggested.dart';

class PrecedentSuggestedCard extends StatefulWidget {
  final PrecedentSuggested suggestedPrecedent;

  const PrecedentSuggestedCard({
    super.key,
    required this.suggestedPrecedent,
  });

  @override
  State<PrecedentSuggestedCard> createState() => _PrecedentSuggestedCardState();
}

class _PrecedentSuggestedCardState extends State<PrecedentSuggestedCard> {
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant PrecedentSuggestedCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.suggestedPrecedent.hasSinteseExplicativa && _expanded) {
      _expanded = false;
    }
  }

  Color get _classificationColor {
    switch (widget.suggestedPrecedent.classificacao) {
      case 2:
        return AppColors.yellow600;
      case 1:
        return AppColors.green600;
      case 0:
      default:
        return AppColors.red600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasSinteseExplicativa = widget.suggestedPrecedent.hasSinteseExplicativa;
    final sinteseExplicativa = widget.suggestedPrecedent.sinteseExplicativaText;
    final similarity = widget.suggestedPrecedent.percentualSimilaridadePercentage;
    final title = widget.suggestedPrecedent.title;
    final tribunalSigla = widget.suggestedPrecedent.tribunalSigla;
    final classification = widget.suggestedPrecedent.classificationLabel;
    final thesis  = widget.suggestedPrecedent.thesis;
    final status = widget.suggestedPrecedent.status;
    final ultimaAtualizacao = widget.suggestedPrecedent.dataAtualizacao;

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: GlassCard(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                title: title,
                tribunalSigla: tribunalSigla,
                titleStyle: textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray100,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: 0,
                ),
                tribunalStyle: textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray100,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 14),
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
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    ultimaAtualizacao,
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.purple200.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gray100.withValues(alpha: 0.7),
                    width: 0.7,
                  ),
                ),
                child: Text(
                  thesis,
                  maxLines: _expanded ? null : 3,
                  overflow:
                      _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray100,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 16,
                  //     vertical: 8,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: _classificationColor,
                  //     borderRadius: BorderRadius.circular(999),
                  //   ),
                  //   child: Text(
                  //     classification,
                  //     maxLines: 1,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: textTheme.bodySmall?.copyWith(
                  //       color: AppColors.gray100,
                  //       fontSize: 10,
                  //       fontWeight: FontWeight.w600,
                  //       height: 1.2,
                  //       letterSpacing: 0,
                  //     ),
                  //   ),
                  // ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'similaridade de',
                        maxLines: 1,
                        textAlign: TextAlign.right,
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
              if (hasSinteseExplicativa) ...[
                const SizedBox(height: 18),
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Síntese explicativa',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.gray100,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.gray100,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (hasSinteseExplicativa && _expanded) ...[
                const SizedBox(height: 14),
                CustomPaint(
                  painter: _TopOutlinePainter(
                    color: AppColors.gray100.withValues(alpha: 0.65),
                    strokeWidth: 0.5,
                    radius: 18,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                    child: Text(
                      sinteseExplicativa,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.gray100,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String tribunalSigla;
  final TextStyle? titleStyle;
  final TextStyle? tribunalStyle;

  const _Header({
    required this.title,
    required this.tribunalSigla,
    required this.titleStyle,
    required this.tribunalStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: titleStyle,
            overflow: TextOverflow.visible,
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
            style: tribunalStyle,
          ),
        ),
      ],
    );
  }
}

class _TopOutlinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  const _TopOutlinePainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    final path =
        Path()
          ..moveTo(0, radius)
          ..quadraticBezierTo(0, 0, radius, 0)
          ..lineTo(size.width - radius, 0)
          ..quadraticBezierTo(size.width, 0, size.width, radius);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TopOutlinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
