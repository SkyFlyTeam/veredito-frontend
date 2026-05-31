import '../../../../analysis/domain/entities/secao_peticao.dart';
import '../../../../petition/domain/entities/peticao.dart';

class MinutaPeticaoState {
  final Peticao peticao;
  final List<SecaoPeticao>? secoes;
  final bool isLoading;
  final String? errorMessage;

  const MinutaPeticaoState({
    required this.peticao,
    this.secoes,
    this.isLoading = false,
    this.errorMessage,
  });

  factory MinutaPeticaoState.initial(Peticao peticao) {
    return MinutaPeticaoState(
      peticao: peticao,
      isLoading: true,
    );
  }

  MinutaPeticaoState copyWith({
    Peticao? peticao,
    List<SecaoPeticao>? secoes,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MinutaPeticaoState(
      peticao: peticao ?? this.peticao,
      secoes: secoes ?? this.secoes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
