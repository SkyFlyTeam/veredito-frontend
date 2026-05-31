import '../precedent_stream_events/precedent_stream_pipeline.dart';

class GeneralInfoEvent extends PrecedentStreamPipelineEvent {
  final String fatos;
  final String fundamentosJuridicos;
  final String pedidos;

  GeneralInfoEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required this.fatos,
    required this.fundamentosJuridicos,
    required this.pedidos,
  });
}