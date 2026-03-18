import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Fundo base (Blue 900)
      body: Stack(
        children: [
          // Elipse Superior Esquerda (Glow Roxo)
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
                        colors: [
                          AppColors.purple800, // Cor pura no gradiente
                          AppColors.background, // Cor pura no gradiente
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Elipse Inferior Direita (Glow Roxo)
          Positioned(
            top: 521,
            left: 55, // Figma positioning
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // CSS: blur(2px)
                child: Opacity(
                  opacity: 0.4, // Fill: 40%
                  child: Container(
                    width: 324,
                    height: 324,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.purple800,
                          AppColors.background,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Conteúdo Principal da Tela
          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }
}
