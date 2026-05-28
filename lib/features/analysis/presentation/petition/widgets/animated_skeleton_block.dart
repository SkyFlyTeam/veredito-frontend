import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

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
