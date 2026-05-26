import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../routes/app_router.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/message_box.dart';
import '../../../../analysis/domain/entities/especie_precedente.dart';
import '../../../../analysis/domain/entities/tribunal_precedente.dart';
import '../../../../analysis/presentation/shared/widgets/filter_bottom_sheet/filters_bottom_sheet.dart';
import '../../../../petition/data/models/peticao_document.dart';
import '../../../../petition/presentation/petition_upload/providers/petition_upload_provider.dart';
import '../../../../petition/presentation/petition_upload/widgets/petition_upload_card.dart';
import '../../../../petition/presentation/shared/providers/petition_documents_provider.dart';

class NewPetitionAnalysisScreen extends ConsumerStatefulWidget {
  const NewPetitionAnalysisScreen({super.key});

  @override
  ConsumerState<NewPetitionAnalysisScreen> createState() =>
      _NewPetitionAnalysisScreenState();
}

class _NewPetitionAnalysisScreenState
    extends ConsumerState<NewPetitionAnalysisScreen> {
  bool _hasUploadError = false;
  final int _uploadCardKey = 0;
  List<EspeciePrecedente> _selectedEspecies = const [];
  List<TribunalPrecedente> _selectedTribunais = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(petitionUploadProvider);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleApplyFilters({
    required List<TribunalPrecedente> tribunais,
    required List<EspeciePrecedente> especies,
  }) {
    setState(() {
      _selectedTribunais = tribunais;
      _selectedEspecies = especies;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final uploadState = ref.watch(petitionUploadProvider);
    final petition = uploadState.petition;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.gray100,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Nova Análise de Petição',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.gray100,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          Text(
            'Arquivo',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.gray100,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          PetitionUploadCard(
            key: ValueKey(_uploadCardKey),
            cardWidth: double.infinity,
            analyzeButtonWidth: double.infinity,
            showAnalyzeButton: false,
            onErrorChanged: (hasError) =>
                setState(() => _hasUploadError = hasError),
            onUploadFile: (fileName, bytes, onProgress) async {
              await ref
                  .read(petitionUploadProvider.notifier)
                  .upload(fileName, bytes, onProgress: onProgress);
              final currentState = ref.read(petitionUploadProvider);
              if (currentState.error != null) {
                throw Exception(currentState.error);
              }
            },
            onUploadComplete: (PeticaoDocument doc) {
              ref
                  .read(petitionDocumentsProvider.notifier)
                  .update((list) => [doc, ...list]);
            },
          ),
          if (_hasUploadError || uploadState.error != null) ...[
            const SizedBox(height: 16),
            MessageBox(
              message: uploadState.error ??
                  'Erro ao enviar arquivo. Verifique as extensões permitidas.',
              variant: MessageBoxVariant.error,
            ),
          ],
          const SizedBox(height: 35),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Analisar documento',
              onPressed: petition == null
                  ? null
                  : () => Navigator.of(context).pushNamed(
                        AppRouter.precedentAnalysis,
                        arguments: petition,
                      ),
              mainAxisSize: MainAxisSize.max,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () => FiltersBottomSheet.show(
                context,
                onApply: _handleApplyFilters,
                initialTribunais: _selectedTribunais,
                initialEspecies: _selectedEspecies,
              ),
              label: 'Refinar Análise',
              mainAxisSize: MainAxisSize.max,
            ),
          ),
        ],
      ),
    );
  }
}