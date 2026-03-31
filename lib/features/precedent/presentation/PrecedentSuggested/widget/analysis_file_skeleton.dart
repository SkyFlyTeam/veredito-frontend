import 'package:flutter/material.dart';

import '../../../../../shared/widgets/glass_card.dart';
import 'animated_skeleton_block.dart';

class AnalysisFileSkeleton extends StatelessWidget {
  const AnalysisFileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Row(
          children: const [
            AnimatedSkeletonBlock(width: 28, height: 34, borderRadius: 8),
            SizedBox(width: 14),
            Expanded(
              child: AnimatedSkeletonBlock(height: 16, borderRadius: 8),
            ),
          ],
        ),
      ),
    );
  }
}
