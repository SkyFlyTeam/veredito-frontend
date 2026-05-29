import 'package:flutter/material.dart';

import '../../../../../shared/widgets/glass_card.dart';
import '../../shared/widgets/precedent_suggestions/animated_skeleton_block.dart';

class PetitionSummarySkeleton extends StatelessWidget {
  const PetitionSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            SizedBox(height: 10),
            AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            SizedBox(height: 10),
            AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            SizedBox(height: 10),
            FractionallySizedBox(
              widthFactor: 0.68,
              child: AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            ),
          ],
        ),
      ),
    );
  }
}
