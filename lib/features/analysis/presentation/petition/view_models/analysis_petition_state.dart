import 'package:flutter/foundation.dart';

import '../../../../../core/utils/file_name_parser.dart';
import '../../../../petition/domain/entities/peticao.dart';
import '../../../domain/entities/precedent_suggested.dart';

class AnalysisPetitionState {
  final Peticao? petition;
  final String? summary;
  final List<PrecedentSuggested>? suggestions;
  final bool? isFileLoadingOverride;
  final bool? isSummaryLoadingOverride;
  final bool? isSuggestionsLoadingOverride;
  final int selectedLimit;

  const AnalysisPetitionState({
    this.petition,
    this.summary,
    this.suggestions,
    this.isFileLoadingOverride,
    this.isSummaryLoadingOverride,
    this.isSuggestionsLoadingOverride,
    this.selectedLimit = 5,
  });

  factory AnalysisPetitionState.initial({
    Peticao? petition,
    String? summary,
    List<PrecedentSuggested>? suggestions,
    bool? isFileLoading,
    bool? isSummaryLoading,
    bool? isSuggestionsLoading,
  }) {
    final hasValidPetition = petition != null && petition.id > 0;
    final resolvedSummary = summary ?? petition?.resumo;
    final hasSummary = resolvedSummary != null && resolvedSummary.trim().isNotEmpty;

    return AnalysisPetitionState(
      petition: petition,
      summary: resolvedSummary,
      suggestions: suggestions,
      isFileLoadingOverride: isFileLoading ?? (hasValidPetition ? false : null),
      isSummaryLoadingOverride: isSummaryLoading ?? (hasValidPetition ? !hasSummary : null),
      isSuggestionsLoadingOverride:
          isSuggestionsLoading ?? (hasValidPetition ? true : null),
    );
  }

  AnalysisPetitionState copyWith({
    Peticao? petition,
    String? summary,
    List<PrecedentSuggested>? suggestions,
    bool? isFileLoadingOverride,
    bool? isSummaryLoadingOverride,
    bool? isSuggestionsLoadingOverride,
    int? selectedLimit,
  }) {
    return AnalysisPetitionState(
      petition: petition ?? this.petition,
      summary: summary ?? this.summary,
      suggestions: suggestions ?? this.suggestions,
      isFileLoadingOverride:
          isFileLoadingOverride ?? this.isFileLoadingOverride,
      isSummaryLoadingOverride:
          isSummaryLoadingOverride ?? this.isSummaryLoadingOverride,
      isSuggestionsLoadingOverride:
          isSuggestionsLoadingOverride ?? this.isSuggestionsLoadingOverride,
      selectedLimit: selectedLimit ?? this.selectedLimit,
    );
  }

  bool get hasFileData {
    final petitionPath = petition?.caminhoArquivo.trim();
    return petitionPath != null && petitionPath.isNotEmpty;
  }

  bool get hasSummaryData {
    final currentSummary = summary?.trim();
    return currentSummary != null && currentSummary.isNotEmpty;
  }

  bool get hasSuggestionsData => suggestions != null;

  bool get isFileLoading => isFileLoadingOverride ?? !hasFileData;

  bool get isSummaryLoading => isSummaryLoadingOverride ?? !hasSummaryData;

  bool get isSuggestionsLoading =>
      isSuggestionsLoadingOverride ?? !hasSuggestionsData;

  List<PrecedentSuggested> get allSuggestions => suggestions ?? const [];

  List<PrecedentSuggested> get visibleSuggestions =>
      allSuggestions.take(selectedLimit).toList();

  String get documentDisplayName {
    final petitionData = petition;
    if (petitionData != null) {
      return extractOriginalFileNameFromPath(petitionData.caminhoArquivo);
    }

    return 'Arquivo não disponível';
  }

  String? get petitionSummary {
    if (!hasSummaryData) {
      return null;
    }

    return summary?.trim();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisPetitionState &&
        other.petition?.id == petition?.id &&
        other.petition?.caminhoArquivo == petition?.caminhoArquivo &&
        other.summary == summary &&
        listEquals(other.suggestions, suggestions) &&
        other.isFileLoadingOverride == isFileLoadingOverride &&
        other.isSummaryLoadingOverride == isSummaryLoadingOverride &&
        other.isSuggestionsLoadingOverride == isSuggestionsLoadingOverride &&
        other.selectedLimit == selectedLimit;
  }

  @override
  int get hashCode {
    return Object.hash(
      petition?.id,
      petition?.caminhoArquivo,
      summary,
      Object.hashAll(suggestions ?? const []),
      isFileLoadingOverride,
      isSummaryLoadingOverride,
      isSuggestionsLoadingOverride,
      selectedLimit,
    );
  }
}
