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

  String _getNumeroRegistro(String numeroRegistro) {
    final numeroRegistroSplit = numeroRegistro.trim().split('-')[-1];
    return "Nº $numeroRegistroSplit";
  }

  String get title {
    final especieNome = precedent?.especieNome;
    final numeroRegistro = _getNumeroRegistro(precedent?.numeroRegistro ?? '');
    return "$especieNome Nº $numeroRegistro";
  }

  String get tribunalSigla {
    return precedent?.tribunalSigla ?? 'Tribunal desconhecido';
  }

  String get thesis {
    return precedent?.tese ?? 'Sem tese disponivel.';
  }
}
