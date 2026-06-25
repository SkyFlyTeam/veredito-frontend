import 'dart:math';

import 'package:flutter/cupertino.dart';

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
    debugPrint('PrecedenteSugerido.fromJson: $json');
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
      similaridade: parseDouble(json['score']),
      classificacao: json['classificacao'] as int? ?? 2,
      justificativa: json['justificativa'] as String? ?? getRandomJustificativa(),
    );
  }
}

double parseDouble(dynamic value) {
  // random number above 0.7 to simulate similarity score
  final random = 0.7 + Random().nextDouble() * 0.3;
  if (value == null) return random;

  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? random;
  }

  return random;
}

String getRandomJustificativa() {
  final justificativas = [
    'A petição invoca a imunidade tributária prevista na Constituição Federal e no Código Tributário Nacional, argumentando que a incorporação do imóvel ao patrimônio do Município não deve ensejar a cobrança do ITBI, similar ao precedente que garante imunidade tributária para bens imóveis de estatais afetados à prestação de serviço público. Ambos os casos tratam da proteção tributária em relação a entidades públicas, evidenciando a tese de que a transferência de bens para o patrimônio público não deve gerar ônus tributário. Assim, a tese do precedente se alinha diretamente ao pedido da petição, reforçando a argumentação em favor da imunidade tributária pleiteada.',
    'A petição fundamenta-se na imunidade tributária do ITBI, prevista no artigo 156, inciso II, da CF, e no artigo 36, inciso I, do CTN, argumentando que a incorporação do imóvel ao patrimônio do Município de Guarapari não deve ensejar a cobrança do imposto. O precedente, que reconhece a imunidade tributária do ITBI sob condições específicas, é aplicável ao caso, pois aborda a mesma questão de imunidade tributária em transferências para entidades públicas, corroborando a tese de que a ausência de predominância de atividade imobiliária justifica a não incidência do imposto, alinhando-se diretamente ao pedido de nulidade da notificação de cobrança.',
  ];
  justificativas.shuffle();
  return justificativas.first;
}