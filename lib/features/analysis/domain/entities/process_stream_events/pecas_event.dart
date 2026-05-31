
import '../peca.dart';
import '../precedent_stream_events/precedent_stream_pipeline.dart';

class PecasEvent extends PrecedentStreamPipelineEvent {
  final List<Peca> pecas;

  PecasEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required this.pecas,
  });
}