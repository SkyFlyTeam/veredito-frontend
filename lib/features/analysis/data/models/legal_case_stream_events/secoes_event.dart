
import '../precedent_stream_events/precedent_stream_pipeline_event.dart';
import '../secao_peticao.dart';

class SecoesEvent extends StreamPipelineEvent {
  final List<SecaoPeticao> secoes;

  SecoesEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required super.data,
    required this.secoes,
  });

  factory SecoesEvent.fromJson(Map<String, dynamic> json) {
    final eventData = json['data'] as Map<String, dynamic>;
    final secoes = (eventData['secoes'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    return SecoesEvent(
      stage: json['stage'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: eventData,
      secoes: secoes.map((s) => SecaoPeticao.fromJson(s)).toList(),
    );
  }
}