import 'precedente.dart';

class PrecedenteSugerido extends Precedente {
  final double similaridade;
  final int? classificacao;
  final String? justificativa;

  PrecedenteSugerido({
    required super.id,
    required super.numeroRegistro,
    super.tese,
    super.questao,
    super.ultimaAtualizacao,
    super.teseVetor,
    super.questaoVetor,
    super.tribunal,
    super.especie,
    super.status,
    required this.similaridade,
    required this.classificacao,
    required this.justificativa,
  });

  factory PrecedenteSugerido.fromJson(Map<String, dynamic> json) {
    final precedente = Precedente.fromJson(json);
    return PrecedenteSugerido(
      id: precedente.id,
      numeroRegistro: precedente.numeroRegistro,
      tese: precedente.tese,
      questao: precedente.questao,
      ultimaAtualizacao: precedente.ultimaAtualizacao,
      teseVetor: precedente.teseVetor,
      questaoVetor: precedente.questaoVetor,
      tribunal: precedente.tribunal,
      especie: precedente.especie,
      status: precedente.status,
      similaridade: (json['score'] as num).toDouble(),
      classificacao: json['classificacao'] as int?,
      justificativa: json['justificativa'] as String?,
    );
  }
}
