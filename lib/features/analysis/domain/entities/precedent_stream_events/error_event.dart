import 'precedent_stream_pipeline.dart';

class ErrorEvent extends PrecedentStreamPipelineEvent {
  final String failedStage;
  final String message;
  final String errorCode;
  final int? precedentId;
  final bool recoverable;

  ErrorEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required this.failedStage,
    required this.message,
    required this.errorCode,
    this.precedentId,
    required this.recoverable,
  });
}
