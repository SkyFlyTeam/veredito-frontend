
import '../entities/especie_precedente.dart';
import '../entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../entities/tribunal_precedente.dart';
import '../repositories/petition_pipeline_repository.dart';

class PetitionPipelineUseCase {
  final PetitionPipelineRepository repository;

  PetitionPipelineUseCase(this.repository);

  Stream<PrecedentStreamPipelineEvent> call(
    int peticaoId,
    List<TribunalPrecedente>? tribunais,
    List<EspeciePrecedente>? especies,
  ) {
    final tribunaisIds = tribunais?.map((t) => t.id).toList();
    final especiesIds = especies?.map((e) => e.id).toList();

    return repository.streamPipeline(peticaoId, tribunaisIds, especiesIds);
  }
}