import '../../domain/repositories/pipeline_stream_repository.dart';
import '../data_sources/pipeline_stream_data_source.dart';
import '../models/pipeline_event_model.dart';

class PipelineStreamRepositoryImpl implements PipelineStreamRepository {
  final PipelineStreamDataSource dataSource;

  PipelineStreamRepositoryImpl(this.dataSource);

  @override
  Stream<PipelineEvent> streamPipeline(int peticaoId) {
    return dataSource.streamPipeline(peticaoId);
  }
}
