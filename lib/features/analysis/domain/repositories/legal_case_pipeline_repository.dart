import '../entities/precedent_stream_events/precedent_stream_pipeline.dart';

abstract class LegalCasePipelineRepository {
  Stream<PrecedentStreamPipelineEvent> streamPipeline(int legalCaseId);

  void cancelStream(int legalCaseId);

  void cancelAll();
}
