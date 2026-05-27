import 'especie_precedente.dart';
import 'status_precedente.dart';
import 'tribunal_precedente.dart';

class Precedent {
  final int id;
  final String numeroRegistro;
  final String? tese;
  final String? questao;
  final DateTime? ultimaAtualizacao;
  final String? teseVetor;
  final String? questaoVetor;
  final TribunalPrecedente? tribunal;
  final StatusPrecedente? status;
  final EspeciePrecedente? especie;

  Precedent({
    required this.id,
    required this.numeroRegistro,
    this.tese,
    this.questao,
    required this.ultimaAtualizacao,
    this.teseVetor,
    this.questaoVetor,
    this.tribunal,
    this.status,
    this.especie,
  });

  String get displayTitle => 'Súmula Nº $numeroRegistro';

  String get displayTribunalSigla {
    final normalizedSigla = tribunal?.sigla.trim();
    if (normalizedSigla != null && normalizedSigla.isNotEmpty) {
      return normalizedSigla;
    }

    final normalizedNome = tribunal?.nome.trim();
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
