class Precedent {
  final int id;
  final String numeroRegistro;
  final String? tese;
  final DateTime? ultimaAtualizacao;
  final String? teseVetor;
  final String? questaoVetor;
  final String? tribunalNome;
  final String? tribunalSigla;
  final String? statusNome;
  final String? especieNome;
  final String? especieSigla;

  Precedent({
    required this.id,
    required this.numeroRegistro,
    required this.tese,
    required this.ultimaAtualizacao,
    required this.teseVetor,
    required this.questaoVetor,
    this.tribunalNome,
    this.tribunalSigla,
    this.statusNome,
    this.especieNome,
    this.especieSigla,
  });

  String get displayTitle => 'Súmula Nº $numeroRegistro';

  String get displayTribunalSigla {
    final normalizedSigla = tribunalSigla?.trim();
    if (normalizedSigla != null && normalizedSigla.isNotEmpty) {
      return normalizedSigla;
    }

    final normalizedNome = tribunalNome?.trim();
    if (normalizedNome != null && normalizedNome.isNotEmpty) {
      return normalizedNome;
    }

    return 'N/D';
  }

  String get displayTese {
    final normalizedTese = tese?.trim();
    if (normalizedTese != null && normalizedTese.isNotEmpty) {
      return normalizedTese;
    }

    return 'Sem tese disponivel.';
  }
}
