import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum MessageBoxVariant { success, error }

class MessageBox extends StatelessWidget {
  final String message;
  final MessageBoxVariant variant;

  const MessageBox({
    super.key,
    required this.message,
    required this.variant,
  });

  Color get _backgroundColor {
    return switch (variant) {
      MessageBoxVariant.success => AppColors.green500,
      MessageBoxVariant.error => AppColors.red300,
    };
  }

  IconData get _icon {
    return switch (variant) {
      MessageBoxVariant.success => Icons.check_circle,
      MessageBoxVariant.error => Icons.error_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Icon(
              _icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
