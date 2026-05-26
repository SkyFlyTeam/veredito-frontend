import 'resumo_event.dart';

class PrecedentStreamPipelineEvent {
  final String stage;
  final String status;
  final String timestamp;
  final int duration;
  final Map<String, dynamic> data;

  PrecedentStreamPipelineEvent({
    required this.stage,
    required this.status,
    required this.timestamp,
    required this.duration,
    required this.data,
  });

  factory PrecedentStreamPipelineEvent.fromJson(Map<String, dynamic> json) {
    final stage = json['stage'] as String;

    switch (stage) {
      case 'resumo':
        return ResumoEvent.fromJson(json);
      case 'search':
        return SearchEvent.fromJson(json);
      case 'synthesis':
        return SynthesisEvent.fromJson(json);
      case 'complete':
        return CompleteEvent.fromJson(json);
      case 'error':
        return ErrorEvent.fromJson(json);
      default:
        return PetitionPipelineEvent(
          stage: stage,
          status: json['status'] as String,
          timestamp: json['timestamp'] as String,
          duration: json['duration'] as int,
          data: json['data'] as Map<String, dynamic>,
        );
    }
  }
}