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
      classificacao: eventData['classificacao'] as int,
      sinteseExplicativa: (eventData['sintese_explicativa'] as String?) ?? '',
      precedenteId: (eventData['precedenteId'] as int?) ?? eventData['precedente_id'] as int? ?? 0,
      entityId: (eventData[entityKey] as int?) ?? 0,
      percentualSimilaridade: parseDouble(eventData['percentual_similaridade']),
    );
  }
}

double? parseDouble(dynamic value) {
  if (value == null) return null;

  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.'));
  }

  return null;
}