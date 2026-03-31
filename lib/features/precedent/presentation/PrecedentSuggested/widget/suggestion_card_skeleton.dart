import 'package:flutter/material.dart';

import '../../../../../shared/widgets/glass_card.dart';
import 'animated_skeleton_block.dart';

class SuggestionCardSkeleton extends StatelessWidget {
  const SuggestionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Expanded(
                  child: AnimatedSkeletonBlock(height: 20, borderRadius: 8),
                ),
                SizedBox(width: 16),
                AnimatedSkeletonBlock(width: 54, height: 24, borderRadius: 999),
              ],
            ),
            SizedBox(height: 18),
            AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            SizedBox(height: 8),
            FractionallySizedBox(
              widthFactor: 0.78,
              child: AnimatedSkeletonBlock(height: 12, borderRadius: 8),
            ),
            SizedBox(height: 22),
            Row(
              children: [
                AnimatedSkeletonBlock(width: 108, height: 28, borderRadius: 999),
                Spacer(),
                AnimatedSkeletonBlock(width: 118, height: 18, borderRadius: 8),
              ],
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: AnimatedSkeletonBlock(width: 128, height: 14, borderRadius: 8),
            ),
          ],
        ),
      ),
    );
  }
}
