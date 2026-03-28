import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../features/account/presentation/login/providers/session_provider.dart';
import '../../../../../shared/layouts/page_layout.dart';
import '../../../../../shared/widgets/app_logo.dart';
import '../../../data/models/peticao_document.dart';
import '../../shared/providers/petition_documents_provider.dart';
import '../widgets/petition_upload_card.dart';

class PetitionUploadScreen extends ConsumerWidget {
  const PetitionUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final textTheme = Theme.of(context).textTheme;

    return PageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppLogo(isHorizontal: true),
          const SizedBox(height: 28),
          Text(
            'Olá, ${user?.nome ?? ''}!',
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Comece a analisar novas petições',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.purple200,
            ),
          ),
          const SizedBox(height: 28),
          PetitionUploadCard(
            onUploadComplete: (PeticaoDocument doc) {
              ref.read(petitionDocumentsProvider.notifier).update(
                (list) => [doc, ...list],
              );
            },
          ),
        ],
      ),
    );
  }
}

