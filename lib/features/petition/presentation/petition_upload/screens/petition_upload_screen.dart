import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/layouts/page_layout.dart';
import '../../../data/models/peticao_document.dart';
import '../../shared/providers/petition_documents_provider.dart';
import '../widgets/petition_upload_card.dart';

class PetitionUploadScreen extends ConsumerWidget {
  const PetitionUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageLayout(
      child: Center(
        child: PetitionUploadCard(
          onUploadComplete: (PeticaoDocument doc) {
            ref.read(petitionDocumentsProvider.notifier).update(
              (list) => [doc, ...list],
            );
          },
        ),
      ),
    );
  }
}
