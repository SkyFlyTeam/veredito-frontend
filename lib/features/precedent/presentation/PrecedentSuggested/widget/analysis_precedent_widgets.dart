import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/glass_card.dart';

class AnalysisSectionTitle extends StatelessWidget {
  final String title;
  final TextTheme textTheme;

  const AnalysisSectionTitle({
    super.key,
    required this.title,
    required this.textTheme,
  });

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

class AnalysisFileSkeleton extends StatelessWidget {
  const AnalysisFileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Row(
          children: const [
            AnimatedSkeletonBlock(width: 28, height: 34, borderRadius: 8),
            SizedBox(width: 14),
            Expanded(
              child: AnimatedSkeletonBlock(height: 16, borderRadius: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class PetitionSummarySkeleton extends StatelessWidget {
  const PetitionSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            SizedBox(height: 10),
            AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            SizedBox(height: 10),
            AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            SizedBox(height: 10),
            FractionallySizedBox(
              widthFactor: 0.68,
              child: AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestionCardsSkeleton extends StatelessWidget {
  const SuggestionCardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SuggestionCardSkeleton(),
        SizedBox(height: 12),
        SuggestionCardSkeleton(),
        SizedBox(height: 12),
        SuggestionCardSkeleton(),
      ],
    );
  }
}

class SuggestionCardSkeleton extends StatelessWidget {
  const SuggestionCardSkeleton({super.key});

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
                  child: AnimatedSkeletonBlock(height: 20, borderRadius: 8),
                ),
                SizedBox(width: 16),
                AnimatedSkeletonBlock(width: 54, height: 24, borderRadius: 999),
              ],
            ),
            SizedBox(height: 18),
            AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            SizedBox(height: 8),
            FractionallySizedBox(
              widthFactor: 0.78,
              child: AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            ),
            SizedBox(height: 22),
            Row(
              children: [
                AnimatedSkeletonBlock(width: 108, height: 28, borderRadius: 999),
                Spacer(),
                AnimatedSkeletonBlock(width: 118, height: 18, borderRadius: 8),
              ],
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: AnimatedSkeletonBlock(width: 128, height: 14, borderRadius: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedSkeletonBlock extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;

  const AnimatedSkeletonBlock({
    super.key,
    this.width,
    required this.height,
    required this.borderRadius,
    this.color,
  });

  @override
  State<AnimatedSkeletonBlock> createState() => _AnimatedSkeletonBlockState();
}

class _AnimatedSkeletonBlockState extends State<AnimatedSkeletonBlock>
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

class SuggestionLimitDropdown extends StatelessWidget {
  final int value;
  final List<int> options;
  final ValueChanged<int?> onChanged;

  const SuggestionLimitDropdown({
    super.key,
    required this.value,
    required this.options,
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
              isExpanded: true,
              itemHeight: 48,
              menuMaxHeight: 192,
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
              items: options
                  .map(
                    (option) => DropdownMenuItem<int>(
                      value: option,
                      child: Text('$option'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderActionButton extends StatelessWidget {
  final IconData icon;

  const HeaderActionButton({
    super.key,
    required this.icon,
  });

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
