import 'precedent_stream_pipeline_event.dart';

class CompleteEvent extends PrecedentStreamPipelineEvent {
  final int totalDurationMs;
  final int precedentsProcessed;
  final int synthesisGenerated;

  CompleteEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required super.data,
    required this.totalDurationMs,
    required this.precedentsProcessed,
    required this.synthesisGenerated,
  });

  factory CompleteEvent.fromJson(Map<String, dynamic> json) {
    final eventData = json['data'] as Map<String, dynamic>;

    return CompleteEvent(
      stage: json['stage'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: eventData,
      totalDurationMs: eventData['totalDurationMs'] as int,
      precedentsProcessed: eventData['precedentsProcessed'] as int,
      synthesisGenerated: eventData['synthesisGenerated'] as int,
    );
  }
}