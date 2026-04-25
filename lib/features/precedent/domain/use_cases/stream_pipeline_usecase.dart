import '../../data/models/pipeline_event_model.dart';
import '../repositories/pipeline_stream_repository.dart';

class StreamPipelineUsecase {
  final PipelineStreamRepository repository;

  StreamPipelineUsecase(this.repository);

  Stream<PipelineEvent> call(int peticaoId) {
    return repository.streamPipeline(peticaoId);
  }
}
