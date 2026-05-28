
import '../entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../repositories/petition_pipeline_repository.dart';

class PetitionPipelineUseCase {
  final PetitionPipelineRepository repository;

  PetitionPipelineUseCase(this.repository);

  Stream<PrecedentStreamPipelineEvent> call(int peticaoId) {
    return repository.streamPipeline(peticaoId);
  }
}