import '../../../../analysis/domain/entities/secao_peticao.dart';
import '../../../../petition/domain/entities/peticao.dart';
import '../../../../precedent/domain/entities/precedent_suggested.dart';

class MinutaPeticaoState {
  final Peticao peticao;
  final List<SecaoPeticao>? secoes;
  final List<PrecedentSuggested>? precedentes;
  final int selectedLimit;
  final bool isMinutaLoading;
  final bool isSuggestionsLoading;
  final String? errorMessage;

  const MinutaPeticaoState({
    required this.peticao,
    this.secoes,
    this.precedentes,
    this.selectedLimit = 5,
    this.isMinutaLoading = false,
    this.isSuggestionsLoading = false,
    this.errorMessage,
  });

  factory MinutaPeticaoState.initial(Peticao peticao) {
    return MinutaPeticaoState(
      peticao: peticao,
      isMinutaLoading: true,
      isSuggestionsLoading: true,
    );
  }

  List<PrecedentSuggested> get visiblePrecedentes =>
      (precedentes ?? const []).take(selectedLimit).toList();

  MinutaPeticaoState copyWith({
    Peticao? peticao,
    List<SecaoPeticao>? secoes,
    List<PrecedentSuggested>? precedentes,
    int? selectedLimit,
    bool? isMinutaLoading,
    bool? isSuggestionsLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MinutaPeticaoState(
      peticao: peticao ?? this.peticao,
      secoes: secoes ?? this.secoes,
      precedentes: precedentes ?? this.precedentes,
      selectedLimit: selectedLimit ?? this.selectedLimit,
      isMinutaLoading: isMinutaLoading ?? this.isMinutaLoading,
      isSuggestionsLoading: isSuggestionsLoading ?? this.isSuggestionsLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
