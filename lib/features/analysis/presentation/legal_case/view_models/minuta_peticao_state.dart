import 'package:flutter/foundation.dart';

import '../../../domain/entities/legal_case.dart';
import '../../../domain/entities/precedent_suggested.dart';
import '../../../domain/entities/secao_peticao.dart';

class MinutaPeticaoState {
  final LegalCase? legalCase;
  final List<SecaoPeticao>? secoes;
  final List<PrecedentSuggested>? precedentes;
  final String? errorMessage;
  final bool? isMinutaLoadingOverride;
  final bool? isSuggestionsLoadingOverride;
  final bool isUpdatingSecao;
  final bool isDownloadingPeticao;
  final int selectedLimit;

  const MinutaPeticaoState({
    this.legalCase,
    this.secoes,
    this.precedentes,
    this.errorMessage,
    this.isMinutaLoadingOverride,
    this.isSuggestionsLoadingOverride,
    this.isUpdatingSecao = false,
    this.isDownloadingPeticao = false,
    this.selectedLimit = 5,
  });

  factory MinutaPeticaoState.initial(LegalCase legalCase) {
    final hasValidCase = legalCase.id > 0;

    return MinutaPeticaoState(
      legalCase: legalCase,
      isMinutaLoadingOverride: hasValidCase ? true : null,
      isSuggestionsLoadingOverride: hasValidCase ? true : null,
    );
  }

  MinutaPeticaoState copyWith({
    LegalCase? legalCase,
    List<SecaoPeticao>? secoes,
    List<PrecedentSuggested>? precedentes,
    String? errorMessage,
    bool clearError = false,
    bool? isMinutaLoadingOverride,
    bool? isSuggestionsLoadingOverride,
    bool? isUpdatingSecao,
    bool? isDownloadingPeticao,
    int? selectedLimit,
  }) {
    return MinutaPeticaoState(
      legalCase: legalCase ?? this.legalCase,
      secoes: secoes ?? this.secoes,
      precedentes: precedentes ?? this.precedentes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isMinutaLoadingOverride:
          isMinutaLoadingOverride ?? this.isMinutaLoadingOverride,
      isSuggestionsLoadingOverride:
          isSuggestionsLoadingOverride ?? this.isSuggestionsLoadingOverride,
      isUpdatingSecao: isUpdatingSecao ?? this.isUpdatingSecao,
      isDownloadingPeticao:
          isDownloadingPeticao ?? this.isDownloadingPeticao,
      selectedLimit: selectedLimit ?? this.selectedLimit,
    );
  }

  bool get hasSecoesData => secoes != null;

  bool get hasPrecedentesData => precedentes != null;

  bool get isMinutaLoading => isMinutaLoadingOverride ?? !hasSecoesData;

  bool get isSuggestionsLoading =>
      isSuggestionsLoadingOverride ?? !hasPrecedentesData;

  List<PrecedentSuggested> get visiblePrecedentes {
    final all = precedentes ?? const [];
    return all.take(selectedLimit).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MinutaPeticaoState &&
        other.legalCase?.id == legalCase?.id &&
        listEquals(other.secoes, secoes) &&
        listEquals(other.precedentes, precedentes) &&
        other.errorMessage == errorMessage &&
        other.isMinutaLoadingOverride == isMinutaLoadingOverride &&
        other.isSuggestionsLoadingOverride == isSuggestionsLoadingOverride &&
        other.isUpdatingSecao == isUpdatingSecao &&
        other.isDownloadingPeticao == isDownloadingPeticao &&
        other.selectedLimit == selectedLimit;
  }

  @override
  int get hashCode {
    return Object.hash(
      legalCase?.id,
      Object.hashAll(secoes ?? const []),
      Object.hashAll(precedentes ?? const []),
      errorMessage,
      isMinutaLoadingOverride,
      isSuggestionsLoadingOverride,
      isUpdatingSecao,
      isDownloadingPeticao,
      selectedLimit,
    );
  }
}
