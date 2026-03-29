import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/layouts/page_layout.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../petition/data/models/peticao_document.dart';
import '../../../../petition/domain/entities/peticao.dart';
import '../../../domain/entities/precedent.dart';
import '../../../domain/entities/precedent_suggested.dart';
import '../widget/PrecedentSuggestedCard.dart';

class AnalysisPrecedentScreen extends StatefulWidget {
  final Peticao? petition;
  final PeticaoDocument? document;
  final List<PrecedentSuggested>? suggestions;
  final bool isLoading;

  const AnalysisPrecedentScreen({
    super.key,
    this.petition,
    this.document,
    this.suggestions,
    this.isLoading = false,
  });

  @override
  State<AnalysisPrecedentScreen> createState() =>
      _AnalysisPrecedentScreenState();
}

class _AnalysisPrecedentScreenState extends State<AnalysisPrecedentScreen> {
  static const String _mockSummary =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim '
      'ad minim veniam, quis nostrud exercitation ullamco laboris ipsum '
      'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor '
      'incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, '
      'quis nostrud exercitation ullamco';

  int _selectedLimit = 10;

  List<PrecedentSuggested> get _allSuggestions {
    return widget.suggestions ?? _buildMockSuggestions();
  }

  List<PrecedentSuggested> get _visibleSuggestions {
    return _allSuggestions.take(_selectedLimit).toList();
  }

  String get _documentDisplayName {
    final document = widget.document;
    if (document != null) {
      final extension = _normalizeExtension(document.extension);
      final fileName = document.fileName.trim();

      if (fileName.toLowerCase().endsWith(extension.toLowerCase())) {
        return fileName;
      }

      return '$fileName$extension';
    }

    final petitionPath = widget.petition?.caminhoArquivo.trim();
    if (petitionPath != null && petitionPath.isNotEmpty) {
      final segments = petitionPath.split(RegExp(r'[\\/]'));
      return segments.isNotEmpty ? segments.last : petitionPath;
    }

    return 'PETIÇÃO 1.pdf';
  }

  String get _petitionSummary {
    final summary = widget.petition?.resumo?.trim();
    if (summary != null && summary.isNotEmpty) {
      return summary;
    }

    return _mockSummary;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PageLayout(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'Analisando Arquivo', textTheme: textTheme),
            const SizedBox(height: 12),
            if (widget.isLoading)
              const _AnalysisFileSkeleton()
            else
              GlassCard(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 20,
                  ),
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
                          _documentDisplayName,
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
              ),
            const SizedBox(height: 28),
            _SectionTitle(title: 'Síntese da Petição', textTheme: textTheme),
            const SizedBox(height: 12),
            if (widget.isLoading)
              const _PetitionSummarySkeleton()
            else
              GlassCard(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                  child: Text(
                    _petitionSummary,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray100,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _SectionTitle(
                    title: 'Petições Sugeridas',
                    textTheme: textTheme,
                  ),
                ),
                _SuggestionLimitDropdown(
                  value: _selectedLimit,
                  onChanged: widget.isLoading
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _selectedLimit = value;
                          });
                        },
                ),
                const SizedBox(width: 8),
                const _HeaderActionButton(icon: Icons.info_outline_rounded),
                const SizedBox(width: 8),
                const _HeaderActionButton(icon: Icons.sort_rounded),
                const SizedBox(width: 8),
                const _HeaderActionButton(icon: Icons.filter_alt_outlined),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.isLoading)
              const _SuggestionCardsSkeleton()
            else if (_visibleSuggestions.isEmpty)
              GlassCard(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 20,
                  ),
                  child: Text(
                    'Nenhuma petição sugerida no momento.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray100,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (
                    var index = 0;
                    index < _visibleSuggestions.length;
                    index++
                  )
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _visibleSuggestions.length - 1
                            ? 0
                            : 12,
                      ),
                      child: PrecedentSuggestedCard(
                        suggestion: _visibleSuggestions[index],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _normalizeExtension(String extension) {
    final normalized = extension.trim();
    if (normalized.isEmpty) {
      return '';
    }

    return normalized.startsWith('.') ? normalized : '.$normalized';
  }

  List<PrecedentSuggested> _buildMockSuggestions() {
    return List.generate(12, (index) {
      final precedentNumber = 387 + index;
      final hasSummary = index.isEven;

      return PrecedentSuggested(
        id: index + 1,
        petitionId: 1,
        precedentId: precedentNumber,
        percentualSimilaridade: 90 - (index * 2).toDouble(),
        classificacao: index % 3,
        sinteseExplicativa: hasSummary
            ? 'Ambas teses tratam sobre os novos procedimentos estéticos que '
                  'causam dano moral e legal.'
            : null,
        precedent: Precedent(
          id: precedentNumber,
          numeroRegistro: '$precedentNumber',
          tese:
              'É lícita a cumulação das indenizações de dano estético e dano moral.',
          ultimaAtualizacao: DateTime(2026, 3, 29),
          teseVetor: null,
          questaoVetor: null,
          tribunalNome: 'Superior Tribunal de Justiça',
          tribunalSigla: 'STJ',
        ),
      );
    });
  }
}

class _AnalysisFileSkeleton extends StatelessWidget {
  const _AnalysisFileSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Row(
          children: const [
            _AnimatedSkeletonBlock(width: 28, height: 34, borderRadius: 8),
            SizedBox(width: 14),
            Expanded(
              child: _AnimatedSkeletonBlock(height: 16, borderRadius: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetitionSummarySkeleton extends StatelessWidget {
  const _PetitionSummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            SizedBox(height: 10),
            _AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            SizedBox(height: 10),
            _AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            SizedBox(height: 10),
            FractionallySizedBox(
              widthFactor: 0.68,
              child: _AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCardsSkeleton extends StatelessWidget {
  const _SuggestionCardsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SuggestionCardSkeleton(),
        SizedBox(height: 12),
        _SuggestionCardSkeleton(),
        SizedBox(height: 12),
        _SuggestionCardSkeleton(),
      ],
    );
  }
}

class _SuggestionCardSkeleton extends StatelessWidget {
  const _SuggestionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Expanded(
                  child: _AnimatedSkeletonBlock(height: 20, borderRadius: 8),
                ),
                SizedBox(width: 16),
                _AnimatedSkeletonBlock(width: 54, height: 24, borderRadius: 999),
              ],
            ),
            SizedBox(height: 18),
            _AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            SizedBox(height: 8),
            FractionallySizedBox(
              widthFactor: 0.78,
              child: _AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            ),
            SizedBox(height: 22),
            Row(
              children: [
                _AnimatedSkeletonBlock(width: 108, height: 28, borderRadius: 999),
                Spacer(),
                _AnimatedSkeletonBlock(width: 118, height: 18, borderRadius: 8),
              ],
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: _AnimatedSkeletonBlock(width: 128, height: 14, borderRadius: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSkeletonBlock extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;

  const _AnimatedSkeletonBlock({
    super.key,
    this.width,
    required this.height,
    required this.borderRadius,
    this.color,
  });

  @override
  State<_AnimatedSkeletonBlock> createState() => _AnimatedSkeletonBlockState();
}

class _AnimatedSkeletonBlockState extends State<_AnimatedSkeletonBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.45,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color ?? AppColors.gray100.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final TextTheme textTheme;

  const _SectionTitle({required this.title, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: textTheme.titleSmall?.copyWith(
        color: AppColors.gray100,
        height: 1.2,
      ),
    );
  }
}

class _SuggestionLimitDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int?>? onChanged;

  const _SuggestionLimitDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              onChanged: onChanged,
              itemHeight: 48,
              menuMaxHeight: 240,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.gray900,
              ),
              dropdownColor: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.gray900,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
              items: List.generate(
                20,
                (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text('${index + 1}'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;

  const _HeaderActionButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.purple300.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, color: AppColors.gray100, size: 22),
      ),
    );
  }
}
