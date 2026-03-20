import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../widgets/app_background.dart';
import '../widgets/app_bottom_navigator.dart';

class PageLayout extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AppBottomNavigator? bottomNavigator;

  const PageLayout({
    super.key,
    required this.child,
    this.padding,
    this.bottomNavigator,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        color: AppColors.background,
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: AppBackground(
            child: Padding(
              padding: padding ?? AppSpacing.pagePadding,
              child: child,
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigator,
    );
  }
}
