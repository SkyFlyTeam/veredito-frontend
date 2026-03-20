import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const GlassCard({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.purple200.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.gray100.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
