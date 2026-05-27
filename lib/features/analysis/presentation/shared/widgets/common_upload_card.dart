import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/message_box.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/petition_upload/providers/petition_upload_provider.dart';
import 'petition_upload_card.dart';
import 'package:flutter_cookiecutter/features/petition/data/models/peticao_document.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/shared/providers/petition_documents_provider.dart';
import 'package:flutter_cookiecutter/routes/app_router.dart';

class CommonUploadCard extends ConsumerStatefulWidget {
  final String title;
  // O petition agora é lido internamente via provider para evitar rebuilds do pai

  const CommonUploadCard({
    super.key,
    required this.title,
  });

  @override
  ConsumerState<CommonUploadCard> createState() => _CommonUploadCardState();
}

class _CommonUploadCardState extends ConsumerState<CommonUploadCard> {
  bool _hasError = false;
  int _uploadCardKey = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentPetition = ref.read(petitionUploadProvider).petition;
        if (currentPetition != null) {
          ref.invalidate(petitionUploadProvider);
          setState(() => _uploadCardKey++);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(petitionUploadProvider);
    final petition = uploadState.petition;
    return SizedBox(
      child: GlassCard(
        width: double.infinity,
        height: 450,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_hasError)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  child: MessageBox(
                    message: 'Erro ao enviar arquivo. Verifique as extensões permitidas.',
                    variant: MessageBoxVariant.error,
                  ),
                ),
              PetitionUploadCard(
                key: ValueKey(_uploadCardKey),
                onErrorChanged: (hasError) => setState(() => _hasError = hasError),
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
                onAnalyze: () async {
                  if (petition == null) return;

                  await Navigator.of(context).pushNamed(
                    AppRouter.precedentAnalysis,
                    arguments: petition,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
