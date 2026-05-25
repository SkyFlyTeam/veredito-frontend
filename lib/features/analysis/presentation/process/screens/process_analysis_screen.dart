import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/glass_card.dart';

class ProcessAnalysisScreen extends ConsumerStatefulWidget {
  const ProcessAnalysisScreen({super.key});

  @override
  ConsumerState<ProcessAnalysisScreen> createState() =>
      _ProcessAnalysisScreenState();
}

class _ProcessAnalysisScreenState extends ConsumerState<ProcessAnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    return (GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.insert_drive_file_rounded,
              size: 34,
              color: AppColors.gray100,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text('', maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    ));
  }
}
