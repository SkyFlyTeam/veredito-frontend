import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/pipeline_stream_data_source.dart';
import '../../../data/models/pipeline_event_model.dart';
import '../../../data/repositories/pipeline_stream_repository_impl.dart';
import '../../../domain/repositories/pipeline_stream_repository.dart';
import '../../../domain/use_cases/stream_pipeline_usecase.dart';

final pipelineStreamDataSourceProvider = Provider<PipelineStreamDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PipelineStreamDataSource(apiClient.sseDio);
});

final pipelineStreamRepositoryProvider = Provider<PipelineStreamRepository>((ref) {
  final dataSource = ref.watch(pipelineStreamDataSourceProvider);
  return PipelineStreamRepositoryImpl(dataSource);
});

final streamPipelineUsecaseProvider = Provider<StreamPipelineUsecase>((ref) {
  final repository = ref.watch(pipelineStreamRepositoryProvider);
  return StreamPipelineUsecase(repository);
});

final streamPipelineProvider = StreamProvider.family<PipelineEvent, int>((
  ref,
  peticaoId,
) {
  final usecase = ref.watch(streamPipelineUsecaseProvider);
  return usecase(peticaoId);
});

final precedentsMapProvider = StateProvider<Map<int, PrecedentBackendDto>>(
  (ref) => {},
);

final synthesisMapProvider = StateProvider<Map<int, SynthesisEvent>>(
  (ref) => {},
);

// Armazena o resumo da petição vindo via SSE
final resumoProvider = StateProvider<String?>((ref) => null);