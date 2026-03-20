import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top-left Ellipse (Purple Glow)
          Positioned(
            top: -78,
            left: -78,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Opacity(
                  opacity: 0.4,
                  child: Container(
                    width: 490,
                    height: 490,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [AppColors.purple800, AppColors.background],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom-right Ellipse (Purple Glow)
          Positioned(
            top: 551,
            left: 90,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Opacity(
                  opacity: 0.4,
                  child: Container(
                    width: 324,
                    height: 324,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [AppColors.purple800, AppColors.background],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Screen Content
          SafeArea(child: child),
        ],
      ),
    );
  }
}
