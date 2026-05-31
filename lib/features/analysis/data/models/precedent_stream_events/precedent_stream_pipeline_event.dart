class StreamPipelineEvent {
  final String stage;
  final String status;
  final String timestamp;
  final int duration;
  final Map<String, dynamic> data;

  StreamPipelineEvent({
    required this.stage,
    required this.status,
    required this.timestamp,
    required this.duration,
    required this.data,
  });
}

typedef StreamPipelineEventFactory = StreamPipelineEvent Function(
  Map<String, dynamic> json, {
  String? entityKey,
});

class StreamPipelineEventParser {
  final Map<String, StreamPipelineEventFactory> _byStage;

  const StreamPipelineEventParser(this._byStage);

  StreamPipelineEvent parse(
    Map<String, dynamic> json, {
    String? entityKey,
  }) {
    final stage = json['stage'] as String;
    final factory = _byStage[stage];

    if (factory != null) {
      return factory(json, entityKey: entityKey);
    }

    return StreamPipelineEvent(
      stage: stage,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: json['data'] as Map<String, dynamic>,
    );
  }
}