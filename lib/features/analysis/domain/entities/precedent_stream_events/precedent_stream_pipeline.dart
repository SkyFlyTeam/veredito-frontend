class PrecedentStreamPipelineEvent {
  final String stage;
  final String status;
  final String timestamp;
  final int duration;

  PrecedentStreamPipelineEvent({
    required this.stage,
    required this.status,
    required this.timestamp,
    required this.duration,
  });

}