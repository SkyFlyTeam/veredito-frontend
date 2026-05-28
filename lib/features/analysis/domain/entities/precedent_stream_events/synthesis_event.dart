import 'precedent_stream_pipeline.dart';

class SynthesisEvent extends PrecedentStreamPipelineEvent {
  final int id;
  final int classificacao;
  final String sinteseExplicativa;
  final int precedenteId;
  final int entityId;
  final double? percentualSimilaridade;

  SynthesisEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required this.id,
    required this.classificacao,
    required this.sinteseExplicativa,
    required this.precedenteId,
    required this.entityId,
    this.percentualSimilaridade,
  });

}