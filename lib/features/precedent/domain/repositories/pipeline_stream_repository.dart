import '../../data/models/pipeline_event_model.dart';

abstract class PipelineStreamRepository {
  Stream<PipelineEvent> streamPipeline(int peticaoId);
}
