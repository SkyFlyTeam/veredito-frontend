import '../entities/precedent_stream_events/precedent_stream_pipeline.dart';

abstract class ProcessPipelineRepository {
  Stream<PrecedentStreamPipelineEvent> streamPipeline(int processoId, List<int>? tribunaisIds, List<int>? especiesIds);

  void cancelStream(int processoId);

  void cancelAll();
}
