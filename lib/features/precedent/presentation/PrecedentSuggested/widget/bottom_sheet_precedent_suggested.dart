import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/text_formater.dart';
import '../../../domain/entities/precedent_suggested.dart';
import '../providers/precedent_suggestions_provider.dart';
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

  @override
  ConsumerState<BottomSheetPrecedentSuggested> createState() =>
      _BottomSheetPrecedentSuggestedState();
}

class _BottomSheetPrecedentSuggestedState
    extends ConsumerState<BottomSheetPrecedentSuggested> {
  bool _isLoadingSintese = false;
  String? _sintese;

  @override
  void initState() {
    super.initState();
    if (widget.isSinteseLoading != null) {
      _isLoadingSintese = widget.isSinteseLoading!;
      if (widget.suggestedPrecedent.hasSinteseExplicativa) {
        _sintese = widget.suggestedPrecedent.sinteseExplicativa;
      }
      return;
    }

    if (widget.suggestedPrecedent.hasSinteseExplicativa) {
      _sintese = widget.suggestedPrecedent.sinteseExplicativa;
    } else if (widget.suggestedPrecedent.id > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchSintese());
    }
  }

  Future<void> _fetchSintese() async {
    var shouldShowLoader = true;
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (!mounted || !shouldShowLoader || _sintese != null) {
        return;
      }

      setState(() {
        _isLoadingSintese = true;
      });
    });

    try {
      final updated = await ref
          .read(precedentRepositoryProvider)
          .getSuggestedPrecedentById(widget.suggestedPrecedent.id);
      if (!mounted) return;
      final raw = updated?.sinteseExplicativa?.trim();
      final resolvedSintese = (raw != null && raw.isNotEmpty) ? raw : null;
      shouldShowLoader = false;
      setState(() {
        _isLoadingSintese = false;
        _sintese = resolvedSintese;
      });
    } catch (_) {
      if (!mounted) return;
      shouldShowLoader = false;
      setState(() => _isLoadingSintese = false);
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
        return AppColors.red500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = widget.suggestedPrecedent.title;
    final tribunalSigla = widget.suggestedPrecedent.tribunalSigla;
    final status = widget.suggestedPrecedent.status;
    final dataAtualizacao = widget.suggestedPrecedent.dataAtualizacao;
    final thesis = widget.suggestedPrecedent.thesis;
    final classification = widget.suggestedPrecedent.classificationLabel;
    final similarity = widget.suggestedPrecedent.percentualSimilaridadePercentage;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final shouldShowSinteseLoading = widget.isSinteseLoading ?? _isLoadingSintese;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.blue800,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.gray200, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
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
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 30 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + tribunal
                  Row(
                    children: [
                      Expanded(
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
                            const Icon(
                              Icons.open_in_new_rounded,
                              size: 12,
                              color: AppColors.gray100,
                            ),
                          ],
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
                  // Status + date
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
                  // Tese section
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
                      border: Border.all(
                        color: AppColors.gray100,
                        width: 0.5,
                      ),
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
                  // Classification + similarity (always shown)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      PrecedentClassificationBadge(
                        label: classification,
                        backgroundColor: _classificationColor,
                        isLoading: widget.isClassificationLoading,
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
                  // Síntese section
                  if (shouldShowSinteseLoading)
                    const _BottomSheetSinteseSkeleton()
                  else if (_sintese != null) ...[
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
                        border: Border.all(
                          color: AppColors.gray100,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        _sintese!,
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
            ),
          ],
        ),
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
