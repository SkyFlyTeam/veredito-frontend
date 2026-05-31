import 'package:flutter/foundation.dart';

import '../../../../../core/utils/file_name_parser.dart';
import '../../../domain/entities/peca.dart';
import '../../../domain/entities/precedent_suggested.dart';
import '../../../domain/entities/processo_juridico.dart';

class AnalysisProcessState {
  final ProcessoJuridico? processo;
  final String? fatos;
  final String? fundamentosJuridicos;
  final String? pedidos;
  final List<Peca>? pecas;
  final List<PrecedentSuggested>? suggestions;
  final bool? isFileLoadingOverride;
  final bool? isGeneralInfoLoadingOverride;
  final bool? isPiecesLoadingOverride;
  final bool? isSuggestionsLoadingOverride;
  final int selectedLimit;

  const AnalysisProcessState({
    this.processo,
    this.fatos,
    this.fundamentosJuridicos,
    this.pedidos,
    this.pecas,
    this.suggestions,
    this.isFileLoadingOverride,
    this.isGeneralInfoLoadingOverride,
    this.isPiecesLoadingOverride,
    this.isSuggestionsLoadingOverride,
    this.selectedLimit = 5,
  });

  factory AnalysisProcessState.initial({
    ProcessoJuridico? processo,
  }) {
    final hasValidProcess = processo != null && (processo.id ?? 0) > 0;

    return AnalysisProcessState(
      processo: processo,
      isFileLoadingOverride: hasValidProcess ? false : null,
      isGeneralInfoLoadingOverride: hasValidProcess ? true : null,
      isPiecesLoadingOverride: hasValidProcess ? true : null,
      isSuggestionsLoadingOverride: hasValidProcess ? true : null,
    );
  }

  AnalysisProcessState copyWith({
    ProcessoJuridico? processo,
    String? fatos,
    String? fundamentosJuridicos,
    String? pedidos,
    List<Peca>? pecas,
    List<PrecedentSuggested>? suggestions,
    bool? isFileLoadingOverride,
    bool? isGeneralInfoLoadingOverride,
    bool? isPiecesLoadingOverride,
    bool? isSuggestionsLoadingOverride,
    int? selectedLimit,
  }) {
    return AnalysisProcessState(
      processo: processo ?? this.processo,
      fatos: fatos ?? this.fatos,
      fundamentosJuridicos: fundamentosJuridicos ?? this.fundamentosJuridicos,
      pedidos: pedidos ?? this.pedidos,
      pecas: pecas ?? this.pecas,
      suggestions: suggestions ?? this.suggestions,
      isFileLoadingOverride: isFileLoadingOverride ?? this.isFileLoadingOverride,
      isGeneralInfoLoadingOverride:
          isGeneralInfoLoadingOverride ?? this.isGeneralInfoLoadingOverride,
      isPiecesLoadingOverride:
          isPiecesLoadingOverride ?? this.isPiecesLoadingOverride,
      isSuggestionsLoadingOverride:
          isSuggestionsLoadingOverride ?? this.isSuggestionsLoadingOverride,
      selectedLimit: selectedLimit ?? this.selectedLimit,
    );
  }

  bool get hasFileData {
    final processPath = processo?.caminhoArquivo.trim();
    return processPath != null && processPath.isNotEmpty;
  }

  bool get hasGeneralInfoData {
    final hasFatos = (fatos ?? '').trim().isNotEmpty;
    final hasFundamentos = (fundamentosJuridicos ?? '').trim().isNotEmpty;
    final hasPedidos = (pedidos ?? '').trim().isNotEmpty;
    return hasFatos || hasFundamentos || hasPedidos;
  }

  bool get hasPiecesData => pecas != null;

  bool get hasSuggestionsData => suggestions != null;

  bool get isFileLoading => isFileLoadingOverride ?? !hasFileData;

  bool get isGeneralInfoLoading =>
      isGeneralInfoLoadingOverride ?? !hasGeneralInfoData;

  bool get isPiecesLoading => isPiecesLoadingOverride ?? !hasPiecesData;

  bool get isSuggestionsLoading =>
      isSuggestionsLoadingOverride ?? !hasSuggestionsData;

  List<Peca> get classifiedPieces => pecas ?? const [];

  List<PrecedentSuggested> get allSuggestions => suggestions ?? const [];

  List<PrecedentSuggested> get visibleSuggestions =>
      allSuggestions.take(selectedLimit).toList();

  String get documentDisplayName {
    final processData = processo;
    if (processData != null) {
      return extractOriginalFileNameFromPath(processData.caminhoArquivo);
    }

    return 'Arquivo nao disponivel';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalysisProcessState &&
        other.processo?.id == processo?.id &&
        other.processo?.caminhoArquivo == processo?.caminhoArquivo &&
        other.fatos == fatos &&
        other.fundamentosJuridicos == fundamentosJuridicos &&
        other.pedidos == pedidos &&
        listEquals(other.pecas, pecas) &&
        listEquals(other.suggestions, suggestions) &&
        other.isFileLoadingOverride == isFileLoadingOverride &&
        other.isGeneralInfoLoadingOverride == isGeneralInfoLoadingOverride &&
        other.isPiecesLoadingOverride == isPiecesLoadingOverride &&
        other.isSuggestionsLoadingOverride == isSuggestionsLoadingOverride &&
        other.selectedLimit == selectedLimit;
  }

  @override
  int get hashCode {
    return Object.hash(
      processo?.id,
      processo?.caminhoArquivo,
      fatos,
      fundamentosJuridicos,
      pedidos,
      Object.hashAll(pecas ?? const []),
      Object.hashAll(suggestions ?? const []),
      isFileLoadingOverride,
      isGeneralInfoLoadingOverride,
      isPiecesLoadingOverride,
      isSuggestionsLoadingOverride,
      selectedLimit,
    );
  }
}
