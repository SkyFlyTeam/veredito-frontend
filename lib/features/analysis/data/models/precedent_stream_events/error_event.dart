import 'precedent_stream_pipeline_event.dart';

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
    required super.data,
    required this.failedStage,
    required this.message,
    required this.errorCode,
    this.precedentId,
    required this.recoverable,
  });

  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    final eventData = json['data'] as Map<String, dynamic>;

    return ErrorEvent(
      stage: json['stage'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: eventData,
      failedStage: (eventData['failedStage'] as String?) ?? '',
      message: (eventData['message'] as String?) ?? '',
      errorCode: (eventData['errorCode'] as String?) ?? '',
      precedentId: eventData['precedentId'] as int?,
      recoverable: (eventData['recoverable'] as bool?) ?? false,
    );
  }
}