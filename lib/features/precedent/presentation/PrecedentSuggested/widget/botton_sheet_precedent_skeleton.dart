import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import 'animated_skeleton_block.dart';

class BottonSheetPrecedentSkeleton extends StatelessWidget {
  const BottonSheetPrecedentSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _SpinningIcon(),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Processando...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.purple100,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
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

class _SpinningIcon extends StatefulWidget {
  const _SpinningIcon();

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Transform.rotate(
        angle: _controller.value * 6.283185307179586,
        child: child,
      ),
      child: const Icon(
        Icons.sync_rounded,
        size: 12,
        color: AppColors.purple100,
      ),
    );
  }
}
