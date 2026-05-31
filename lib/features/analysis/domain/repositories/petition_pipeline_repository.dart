import '../entities/precedent_stream_events/precedent_stream_pipeline.dart';

abstract class PetitionPipelineRepository {
  Stream<PrecedentStreamPipelineEvent> streamPipeline(
    int peticaoId,
    List<int>? tribunaisIds,
    List<int>? especiesIds,
  );

  void cancelStream(int peticaoId);

  void cancelAll();
}
