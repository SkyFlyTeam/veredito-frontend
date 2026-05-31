

import '../entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../repositories/legal_case_pipeline_repository.dart';

class LegalCasePipelineUseCase {
  final LegalCasePipelineRepository repository;

  LegalCasePipelineUseCase(this.repository);

  Stream<PrecedentStreamPipelineEvent> call(int legalCaseId) {

    return repository.streamPipeline(legalCaseId);
  }
}