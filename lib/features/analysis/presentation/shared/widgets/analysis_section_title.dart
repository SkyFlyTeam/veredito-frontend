import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

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
