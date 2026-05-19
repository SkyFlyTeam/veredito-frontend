import '../../data/models/petition_pipeline_event.dart';

abstract class PetitionPipelineRepository {
  Stream<PetitionPipelineEvent> streamPipeline(int peticaoId);

  void cancelStream(int peticaoId);

  void cancelAll();
}
