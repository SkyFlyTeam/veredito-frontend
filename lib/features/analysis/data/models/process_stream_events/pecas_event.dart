import '../peca.dart';
import '../precedent_stream_events/precedent_stream_pipeline_event.dart';

class PecasEvent extends StreamPipelineEvent {
  final List<Peca> pecas;

  PecasEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required super.data,
    required this.pecas,
  });

  factory PecasEvent.fromJson(Map<String, dynamic> json) {
    final eventData = json['data'] as Map<String, dynamic>;
    final pieces = (eventData['pieces'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    return PecasEvent(
      stage: json['stage'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: eventData,
      pecas: pieces.map((p) => Peca.fromJson(p)).toList(),
    );
  }
}