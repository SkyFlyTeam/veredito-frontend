import '../../data/models/petition_pipeline_event.dart';
import '../repositories/petition_pipeline_repository.dart';

class PetitionPipelineUseCase {
  final PetitionPipelineRepository repository;

  PetitionPipelineUseCase(this.repository);

  Stream<PetitionPipelineEvent> call(int peticaoId) {
    return repository.streamPipeline(peticaoId);
  }
}