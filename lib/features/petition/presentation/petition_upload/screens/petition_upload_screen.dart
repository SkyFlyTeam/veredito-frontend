import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../features/account/presentation/login/providers/session_provider.dart';
import '../../../../../shared/layouts/page_layout.dart';
import '../../../../../shared/widgets/app_logo.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/message_box.dart';
import '../../../data/models/peticao_document.dart';
import '../../shared/providers/petition_documents_provider.dart';
import '../providers/petition_upload_provider.dart';
import '../widgets/petition_upload_card.dart';
import '../../../../../routes/app_router.dart';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 1), // Para manter o título centralizado
              Text(
                'Olá, ${user?.nome ?? ''}!',
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  height: 1.2,
                ),
              ),
              IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.precedentAnalysis);
            },
            icon: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 28,
            ),
            tooltip: 'Abrir análise de precedentes',
          ),
            ],
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
          SizedBox(
            child: GlassCard(
              width: double.infinity,
              height: 500,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    Text(
                      'Enviar Petição Inicial',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Visibility(
                      visible: _hasError,
                      maintainSize: false,
                      maintainAnimation: true,
                      maintainState: true,
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
                          child: MessageBox(
                            message:
                                'Erro ao enviar arquivo. Verifique as extensões permitidas.',
                            variant: MessageBoxVariant.error,
                          ),
                        ),
                      ),
                    ),
                    PetitionUploadCard(
                      onErrorChanged: (hasError) =>
                          setState(() => _hasError = hasError),
                      onUploadFile: (fileName, bytes, onProgress) async {
                        await ref
                            .read(petitionUploadProvider.notifier)
                            .upload(fileName, bytes, onProgress: onProgress);
                        final uploadState = ref.read(petitionUploadProvider);
                        if (uploadState.error != null) {
                          throw Exception(uploadState.error);
                        }
                      },
                      onUploadComplete: (PeticaoDocument doc) {
                        ref
                            .read(petitionDocumentsProvider.notifier)
                            .update((list) => [doc, ...list]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
