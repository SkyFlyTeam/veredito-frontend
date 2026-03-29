import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/layouts/page_layout.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../petition/data/models/peticao_document.dart';
import '../../../../petition/domain/entities/peticao.dart';
import '../../../domain/entities/precedent.dart';
import '../../../domain/entities/precedent_suggested.dart';
import '../widget/PrecedentSuggestedCard.dart';
import '../widget/analysis_precedent_widgets.dart';

class AnalysisPrecedentScreen extends StatefulWidget {
  final Peticao? petition;
  final PeticaoDocument? document;
  final List<PrecedentSuggested>? suggestions;
  final bool isLoading;

  const AnalysisPrecedentScreen({
    super.key,
    this.petition,
    this.document,
    this.suggestions,
    this.isLoading = false,
  });

  @override
  State<AnalysisPrecedentScreen> createState() =>
      _AnalysisPrecedentScreenState();
}

class _AnalysisPrecedentScreenState extends State<AnalysisPrecedentScreen> {
  static const List<int> _suggestionLimitOptions = [1, 5, 10, 15];
  static const String _mockSummary =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim '
      'ad minim veniam, quis nostrud exercitation ullamco laboris ipsum '
      'dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor '
      'incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, '
      'quis nostrud exercitation ullamco';

  int _selectedLimit = 5;

  List<PrecedentSuggested> get _allSuggestions {
    return widget.suggestions ?? _buildMockSuggestions();
  }

  List<PrecedentSuggested> get _visibleSuggestions {
    return _allSuggestions.take(_selectedLimit).toList();
  }

  String get _documentDisplayName {
    final document = widget.document;
    if (document != null) {
      final extension = _normalizeExtension(document.extension);
      final fileName = document.fileName.trim();

      if (fileName.toLowerCase().endsWith(extension.toLowerCase())) {
        return fileName;
      }

      return '$fileName$extension';
    }

    final petitionPath = widget.petition?.caminhoArquivo.trim();
    if (petitionPath != null && petitionPath.isNotEmpty) {
      final segments = petitionPath.split(RegExp(r'[\\/]'));
      return segments.isNotEmpty ? segments.last : petitionPath;
    }

    return 'PETIÇÃO 1.pdf';
  }

  String get _petitionSummary {
    final summary = widget.petition?.resumo?.trim();
    if (summary != null && summary.isNotEmpty) {
      return summary;
    }

    return _mockSummary;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PageLayout(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnalysisSectionTitle(
              title: 'Analisando Arquivo',
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            if (widget.isLoading)
              const AnalysisFileSkeleton()
            else
              GlassCard(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file_rounded,
                        size: 34,
                        color: AppColors.gray100,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _documentDisplayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.gray100,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 28),
            AnalysisSectionTitle(
              title: 'Síntese da Petição',
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            if (widget.isLoading)
              const PetitionSummarySkeleton()
            else
              GlassCard(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                  child: Text(
                    _petitionSummary,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray100,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AnalysisSectionTitle(
                    title: 'Petições Sugeridas',
                    textTheme: textTheme,
                  ),
                ),
                SuggestionLimitDropdown(
                  value: _selectedLimit,
                  options: _suggestionLimitOptions,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedLimit = value;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const HeaderActionButton(icon: Icons.info_outline_rounded),
                const SizedBox(width: 8),
                const HeaderActionButton(icon: Icons.sort_rounded),
                const SizedBox(width: 8),
                const HeaderActionButton(icon: Icons.filter_alt_outlined),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.isLoading)
              const SuggestionCardsSkeleton()
            else if (_visibleSuggestions.isEmpty)
              GlassCard(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 20,
                  ),
                  child: Text(
                    'Nenhuma petição sugerida no momento.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray100,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (
                    var index = 0;
                    index < _visibleSuggestions.length;
                    index++
                  )
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _visibleSuggestions.length - 1
                            ? 0
                            : 12,
                      ),
                      child: PrecedentSuggestedCard(
                        suggestion: _visibleSuggestions[index],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _normalizeExtension(String extension) {
    final normalized = extension.trim();
    if (normalized.isEmpty) {
      return '';
    }

    return normalized.startsWith('.') ? normalized : '.$normalized';
  }

  List<PrecedentSuggested> _buildMockSuggestions() {
    return List.generate(12, (index) {
      final precedentNumber = 387 + index;
      final hasSummary = index.isEven;

      return PrecedentSuggested(
        id: index + 1,
        petitionId: 1,
        precedentId: precedentNumber,
        percentualSimilaridade: 90 - (index * 2).toDouble(),
        classificacao: index % 3,
        sinteseExplicativa: hasSummary
            ? 'Ambas teses tratam sobre os novos procedimentos estéticos que '
                  'causam dano moral e legal.'
            : null,
        precedent: Precedent(
          id: precedentNumber,
          numeroRegistro: '$precedentNumber',
          tese:
              'É lícita a cumulação das indenizações de dano estético e dano moral.',
          ultimaAtualizacao: DateTime(2026, 3, 29),
          teseVetor: null,
          questaoVetor: null,
          tribunalNome: 'Superior Tribunal de Justiça',
          tribunalSigla: 'STJ',
        ),
      );
    });
  }
}
