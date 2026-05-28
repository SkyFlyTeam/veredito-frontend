import 'precedent_stream_pipeline.dart';

class ResumoEvent extends PrecedentStreamPipelineEvent {
  final String resumo;

  ResumoEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required this.resumo,
  });
}
