import 'precedent.dart';

class PrecedentSuggested {
  final int id;
  final int petitionId;
  final int precedentId;
  final double percentualSimilaridade;
  final int classificacao;
  final String? sinteseExplicativa;
  final Precedent? precedent;

  PrecedentSuggested({
    required this.id,
    required this.petitionId,
    required this.precedentId,
    required this.percentualSimilaridade,
    required this.classificacao,
    required this.sinteseExplicativa,
    this.precedent,
  });

  bool get hasSinteseExplicativa {
    return sinteseExplicativa?.trim().isNotEmpty ?? false;
  }

  String get resolvedTitle {
    return precedent?.displayTitle ?? 'Súmula Nº $precedentId';
  }

  String get resolvedTribunalSigla {
    return precedent?.displayTribunalSigla ?? 'N/D';
  }

  String get resolvedThesis {
    return precedent?.displayTese ?? 'Sem tese disponivel.';
  }
}
