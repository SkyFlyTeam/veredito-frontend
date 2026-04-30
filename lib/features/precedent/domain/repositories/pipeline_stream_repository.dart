import '../../data/models/pipeline_event_model.dart';

abstract class PipelineStreamRepository {
  Stream<PipelineEvent> streamPipeline(int peticaoId);

  void cancelStream(int peticaoId);

  void cancelAll();
}
