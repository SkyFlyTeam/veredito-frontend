

import '../../domain/repositories/petition_pipeline_repository.dart';
import '../data_sources/petition_pipeline_remote_data_source.dart';
import '../models/precedent_stream_pipeline_event.dart';

class PetitionPipelineRepositoryImpl implements PetitionPipelineRepository {
  final PetitionPipelineRemoteDataSource dataSource;

  PetitionPipelineRepositoryImpl(this.dataSource);

  @override
  Stream<PrecedentStreamPipelineEvent> streamPipeline(int peticaoId) {
    return dataSource.streamPipeline(peticaoId);
  }

  @override
  void cancelStream(int peticaoId) {
    dataSource.cancelStream(peticaoId);
  }

  @override
  void cancelAll() {
    dataSource.cancelAll();
  }
}
