

import '../entities/especie_precedente.dart';
import '../entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../entities/tribunal_precedente.dart';
import '../repositories/process_pipeline_repository.dart';

class ProcessPipelineUseCase {
  final ProcessPipelineRepository repository;

  ProcessPipelineUseCase(this.repository);

  Stream<PrecedentStreamPipelineEvent> call(int processoId, List<TribunalPrecedente>? tribunais, List<EspeciePrecedente>? especies) {
    final tribunaisIds = tribunais?.map((t) => t.id).toList();
    final especiesIds = especies?.map((e) => e.id).toList();

    return repository.streamPipeline(processoId, tribunaisIds, especiesIds);
  }
}