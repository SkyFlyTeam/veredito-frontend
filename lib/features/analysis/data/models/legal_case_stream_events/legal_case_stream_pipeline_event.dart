import '../precedent_stream_events/complete_event.dart';
import '../precedent_stream_events/error_event.dart';
import '../precedent_stream_events/precedent_stream_pipeline_event.dart';
import '../precedent_stream_events/search_event.dart';
import '../precedent_stream_events/synthesis_event.dart';
import 'secoes_event.dart';


class LegalCaseStreamPipelineEvent extends StreamPipelineEvent {
  LegalCaseStreamPipelineEvent({required super.stage, required super.status, required super.timestamp, required super.duration, required super.data});

  static final StreamPipelineEventParser _parser = StreamPipelineEventParser({
    'secoes': (json, {entityKey}) => SecoesEvent.fromJson(json),
    'search': (json, {entityKey}) => SearchEvent.fromJson(json),
    'synthesis': (json, {entityKey}) => SynthesisEvent.fromJson(
          json,
          entityKey: entityKey ?? 'casoJuridicoId',
        ),
    'complete': (json, {entityKey}) => CompleteEvent.fromJson(json),
    'error': (json, {entityKey}) => ErrorEvent.fromJson(json),
  });

  static StreamPipelineEvent fromJson(
    Map<String, dynamic> json,
    String entityKey,
  ) {
    return _parser.parse(json, entityKey: entityKey);
  }
}