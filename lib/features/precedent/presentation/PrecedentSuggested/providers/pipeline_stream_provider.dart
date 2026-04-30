import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/pipeline_stream_data_source.dart';
import '../../../data/models/pipeline_event_model.dart';
import '../../../data/repositories/pipeline_stream_repository_impl.dart';
import '../../../domain/repositories/pipeline_stream_repository.dart';
import '../../../domain/use_cases/stream_pipeline_usecase.dart';

/// Provides the data source for pipeline stream operations
final pipelineStreamDataSourceProvider = Provider<PipelineStreamDataSource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return PipelineStreamDataSource(apiClient.dio);
});

/// Provides the repository for pipeline stream operations
final pipelineStreamRepositoryProvider = Provider<PipelineStreamRepository>((
  ref,
) {
  final dataSource = ref.read(pipelineStreamDataSourceProvider);
  return PipelineStreamRepositoryImpl(dataSource);
});

/// Provides the use case for streaming pipeline events
final streamPipelineUsecaseProvider = Provider<StreamPipelineUsecase>((ref) {
  final repository = ref.read(pipelineStreamRepositoryProvider);
  return StreamPipelineUsecase(repository);
});

/// Provides the stream of pipeline events for a given petition ID
final pipelineStreamProvider = StreamProvider.family<PipelineEvent, int>((
  ref,
  petitionId,
) {
  final usecase = ref.read(streamPipelineUsecaseProvider);
  return usecase.call(petitionId);
});

/// Provides a callback to cancel the SSE stream for a given petition ID
final pipelineStreamCancelProvider = Provider.family<void Function(), int>((
  ref,
  petitionId,
) {
  final repository = ref.read(pipelineStreamRepositoryProvider);
  return () {
    repository.cancelStream(petitionId);
  };
});

/// Provides a callback to cancel all active SSE streams
final pipelineStreamCancelAllProvider = Provider<void Function()>((ref) {
  final repository = ref.read(pipelineStreamRepositoryProvider);
  return () {
    repository.cancelAll();
  };
});
