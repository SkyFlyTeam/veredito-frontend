import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../features/account/presentation/login/providers/session_provider.dart';
import '../../../../../shared/layouts/page_layout.dart';
import '../../../../../shared/widgets/app_logo.dart';
import '../../../../../shared/widgets/message_box.dart';
import '../../../data/models/peticao_document.dart';
import '../../shared/providers/petition_documents_provider.dart';
import '../widgets/petition_upload_card.dart';

class PetitionUploadScreen extends ConsumerStatefulWidget {
  const PetitionUploadScreen({super.key});

  @override
  ConsumerState<PetitionUploadScreen> createState() =>
      _PetitionUploadScreenState();
}

class _PetitionUploadScreenState extends ConsumerState<PetitionUploadScreen> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final textTheme = Theme.of(context).textTheme;

    return PageLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: AppLogo(isHorizontal: true, iconHeight: 24)),
          const SizedBox(height: 32),
          Text(
            'Olá, ${user?.nome ?? ''}!',
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            'Comece a analisar novas petições',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.purple200,
              fontSize: 13,
              height: 1.23,
            ),
          ),
          const SizedBox(height: 56),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0x1A726DFF),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 19),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Enviar Petição Inicial',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Visibility(
                    visible: _hasError,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: SizedBox(
                      width: 290,
                      child: MessageBox(
                        message: 'Erro ao enviar arquivo. Verifique as extensões permitidas.',
                        variant: MessageBoxVariant.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PetitionUploadCard(
                    onErrorChanged: (hasError) =>
                        setState(() => _hasError = hasError),
                    onUploadComplete: (PeticaoDocument doc) {
                      ref.read(petitionDocumentsProvider.notifier).update(
                        (list) => [doc, ...list],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

