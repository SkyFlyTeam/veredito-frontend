

import '../precedent_stream_events/precedent_stream_pipeline.dart';
import '../secao_peticao.dart';

class SecoesEvent extends PrecedentStreamPipelineEvent {
  final List<SecaoPeticao> secoes;

  SecoesEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required this.secoes,
  });

}