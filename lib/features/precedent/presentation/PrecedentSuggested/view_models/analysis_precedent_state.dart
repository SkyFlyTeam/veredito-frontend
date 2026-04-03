import 'package:flutter/foundation.dart';

import '../../../../../core/utils/file_name_parser.dart';
import '../../../../petition/domain/entities/peticao.dart';
import '../../../domain/entities/precedent_suggested.dart';

class AnalysisPrecedentState {
  final Peticao? petition;
  final List<PrecedentSuggested>? suggestions;
  final bool? isFileLoadingOverride;
  final bool? isSummaryLoadingOverride;
  final bool? isSuggestionsLoadingOverride;
  final int selectedLimit;

  const AnalysisPrecedentState({
    this.petition,
    this.suggestions,
    this.isFileLoadingOverride,
    this.isSummaryLoadingOverride,
    this.isSuggestionsLoadingOverride,
    this.selectedLimit = 5,
  });

  factory AnalysisPrecedentState.initial({
    Peticao? petition,
    List<PrecedentSuggested>? suggestions,
    bool? isFileLoading,
    bool? isSummaryLoading,
    bool? isSuggestionsLoading,
  }) {
    return AnalysisPrecedentState(
      petition: petition,
      suggestions: suggestions,
      isFileLoadingOverride: isFileLoading,
      isSummaryLoadingOverride: isSummaryLoading,
      isSuggestionsLoadingOverride: isSuggestionsLoading,
    );
  }

  AnalysisPrecedentState copyWith({
    Peticao? petition,
    List<PrecedentSuggested>? suggestions,
    bool? isFileLoadingOverride,
    bool? isSummaryLoadingOverride,
    bool? isSuggestionsLoadingOverride,
    int? selectedLimit,
  }) {
    return AnalysisPrecedentState(
      petition: petition ?? this.petition,
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
    final summary = petition?.resumo?.trim();
    return summary != null && summary.isNotEmpty;
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

    return petition?.resumo?.trim();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisPrecedentState &&
        other.petition?.id == petition?.id &&
        other.petition?.caminhoArquivo == petition?.caminhoArquivo &&
        other.petition?.resumo == petition?.resumo &&
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
      petition?.resumo,
      Object.hashAll(suggestions ?? const []),
      isFileLoadingOverride,
      isSummaryLoadingOverride,
      isSuggestionsLoadingOverride,
      selectedLimit,
    );
  }
}
