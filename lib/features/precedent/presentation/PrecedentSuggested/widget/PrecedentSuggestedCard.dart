import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../data/models/pipeline_event_model.dart';
import '../../../domain/entities/precedent_suggested.dart';
import '../view_models/precedent_card_data.dart';

class PrecedentSuggestedCard extends StatefulWidget {
  final PrecedentCardData data;
  final VoidCallback? onTap;

  const PrecedentSuggestedCard({super.key, required this.data, this.onTap});

  factory PrecedentSuggestedCard.fromSuggested({
    Key? key,
    required PrecedentSuggested suggestedPrecedent,
    VoidCallback? onTap,
  }) {
    return PrecedentSuggestedCard(
      key: key,
      data: PrecedentCardData.fromSuggested(suggestedPrecedent),
      onTap: onTap,
    );
  }

  factory PrecedentSuggestedCard.fromSSE({
    Key? key,
    required PrecedentBackendDto precedent,
    SynthesisEvent? synthesis,
    VoidCallback? onTap,
  }) {
    return PrecedentSuggestedCard(
      key: key,
      data: PrecedentCardData.fromSSE(
        precedent: precedent,
        synthesis: synthesis,
      ),
      onTap: onTap,
    );
  }

  @override
  State<PrecedentSuggestedCard> createState() => _PrecedentSuggestedCardState();
}

class _PrecedentSuggestedCardState extends State<PrecedentSuggestedCard> {
  Color get _classificationColor {
    switch (widget.data.classificacao) {
      case 2:
        return AppColors.green600;
      case 1:
        return AppColors.yellow600;
      case 0:
      default:
        return AppColors.red600;
    }
  }

  String get _classificationLabel {
    switch (widget.data.classificacao) {
      case 2:
        return 'Aplicável';
      case 1:
        return 'Possivelmente Aplicável';
      case 0:
      default:
        return 'Não Aplicável';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final data = widget.data;

    return GestureDetector(
      onTap: widget.onTap,
      child: GlassCard(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                title: data.title,
                tribunalSigla: data.tribunalSigla,
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
              if (data.dataAtualizacao.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.blue200,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      data.dataAtualizacao,
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
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.purple200.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gray100.withValues(alpha: 0.7),
                    width: 0.7,
                  ),
                ),
                child: Text(
                  data.thesis,
                  maxLines: 3,
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
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Badge esquerdo — Processando... ou classificação
                  if (data.classificacao == null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.purple100,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Processando...',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.purple100,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _classificationColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _classificationLabel,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  const Spacer(),
                  // Percentual direito — sempre visível
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
                        data.percentualSimilaridadePercentage,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingShimmer extends StatefulWidget {
  final double width;
  final double height;

  const _LoadingShimmer({required this.width, required this.height});

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.2, end: 0.5).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.gray100.withValues(alpha: _animation.value),
          borderRadius: BorderRadius.circular(6),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.purple200,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(tribunalSigla, style: tribunalStyle),
        ),
      ],
    );
  }
}
