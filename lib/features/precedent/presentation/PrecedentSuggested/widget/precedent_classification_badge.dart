import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class PrecedentClassificationBadge extends StatelessWidget {
  final bool isLoading;
  final String label;
  final Color backgroundColor;

  const PrecedentClassificationBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SpinningIcon(),
          const SizedBox(width: 8),
          Text(
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
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.gray100,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
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
