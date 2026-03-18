import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class PageLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const PageLayout({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Padding(
          padding: padding ?? AppSpacing.pagePadding,
          child: child,
        ),
      ),
    );
  }
}
