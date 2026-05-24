import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/glass_card.dart';

class AnalysisItemCard extends StatelessWidget {
  final String name;
  final String description;
  final VoidCallback onTap;

  const AnalysisItemCard({
    super.key,
    required this.name,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 330,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/ic_file_document.png',
                      width: 39,
                      height: 39,
                      color: AppColors.gray100,
                    ),
                    const SizedBox(width: 15),
                    SizedBox(
                      width: 176,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.gray100,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color: AppColors.gray100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.gray100,
                  size: 29,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
