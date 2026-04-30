import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class HeaderActionButton extends StatelessWidget {
  final IconData icon;

  const HeaderActionButton({super.key, required this.icon});

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
