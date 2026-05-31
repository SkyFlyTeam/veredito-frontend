import '../precedent_stream_events/precedent_stream_pipeline_event.dart';

class ResumoEvent extends StreamPipelineEvent {
  final String resumo;

  ResumoEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required super.data,
    required this.resumo,
  });

  factory ResumoEvent.fromJson(Map<String, dynamic> json) {
    final eventData = json['data'] as Map<String, dynamic>;

    return ResumoEvent(
      stage: json['stage'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: eventData,
      resumo: (eventData['resumo'] as String?) ?? '',
    );
  }
}
