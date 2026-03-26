import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/layouts/page_layout.dart';
import '../../shared/providers/petition_documents_provider.dart';
import '../widgets/petition_document_card.dart';

class PetitionHistoryScreen extends ConsumerWidget {
  const PetitionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: substituir por chamada real à API quando o backend estiver pronto
    final documents = ref.watch(petitionDocumentsProvider);

    return PageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Meus Documentos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${documents.length} documento${documents.length == 1 ? '' : 's'} encontrado${documents.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.gray300,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: documents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_open_outlined,
                          color: AppColors.gray300.withValues(alpha: 0.4),
                          size: 56,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum documento ainda',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.gray300,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Faça o upload de uma petição\npara vê-la aqui.',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray300.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: documents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return PetitionDocumentCard(document: documents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
