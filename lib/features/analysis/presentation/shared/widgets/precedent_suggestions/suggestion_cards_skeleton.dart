import 'package:flutter/material.dart';

import 'suggestion_card_skeleton.dart';

class SuggestionCardsSkeleton extends StatelessWidget {
  const SuggestionCardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SuggestionCardSkeleton(),
        SizedBox(height: 12),
        SuggestionCardSkeleton(),
        SizedBox(height: 12),
        SuggestionCardSkeleton(),
      ],
    );
  }
}
