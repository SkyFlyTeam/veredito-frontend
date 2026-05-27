import '../../data/models/precedent_stream_pipeline_event.dart';

abstract class PetitionPipelineRepository {
  Stream<PrecedentStreamPipelineEvent> streamPipeline(int peticaoId);

  void cancelStream(int peticaoId);

  void cancelAll();
}
