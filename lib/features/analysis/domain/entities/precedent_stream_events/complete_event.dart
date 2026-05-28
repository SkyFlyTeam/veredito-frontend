import 'precedent_stream_pipeline.dart';

class CompleteEvent extends PrecedentStreamPipelineEvent {
  final int totalDurationMs;
  final int precedentsProcessed;
  final int synthesisGenerated;

  CompleteEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required this.totalDurationMs,
    required this.precedentsProcessed,
    required this.synthesisGenerated,
  });

}