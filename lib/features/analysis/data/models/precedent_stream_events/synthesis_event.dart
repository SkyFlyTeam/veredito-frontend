import 'dart:math';

import 'precedent_stream_pipeline_event.dart';

class SynthesisEvent extends StreamPipelineEvent {
  final int id;
  final int classificacao;
  final String sinteseExplicativa;
  final int precedenteId;
  final int entityId;
  final double? percentualSimilaridade;

  SynthesisEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required super.data,
    required this.id,
    required this.classificacao,
    required this.sinteseExplicativa,
    required this.precedenteId,
    required this.entityId,
    this.percentualSimilaridade,
  });

  factory SynthesisEvent.fromJson(Map<String, dynamic> json, {required String entityKey}) {
    final eventData = json['data'] as Map<String, dynamic>;

    return SynthesisEvent(
      stage: json['stage'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: eventData,
      id: (eventData['id'] as int?) ?? 0,
      classificacao: eventData['classificacao'] as int? ?? 2,
      sinteseExplicativa: (eventData['sintese_explicativa'] as String?) ?? getRandomJustificativa(),
      precedenteId: (eventData['precedenteId'] as int?) ?? eventData['precedente_id'] as int? ?? 0,
      entityId: (eventData[entityKey] as int?) ?? 0,
      percentualSimilaridade: parseDouble(eventData['percentual_similaridade']),
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