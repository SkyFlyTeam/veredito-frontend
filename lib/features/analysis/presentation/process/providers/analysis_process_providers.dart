import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/process_pipeline_remote_data_souce.dart';
import '../../../data/repositories/process_pipeline_repository_impl.dart';
import '../../../domain/entities/especie_precedente.dart';
import '../../../domain/entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../../../domain/entities/tribunal_precedente.dart';
import '../../../domain/repositories/process_pipeline_repository.dart';
import '../../../domain/use_cases/process_pipeline_use_case.dart';
import '../view_models/analysis_process_state.dart';
import '../view_models/analysis_process_view_model.dart';

class ProcessPipelineParams {
  final int processoId;
  final List<TribunalPrecedente> tribunais;
  final List<EspeciePrecedente> especies;

  const ProcessPipelineParams({
    required this.processoId,
    required this.tribunais,
    required this.especies,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProcessPipelineParams &&
        other.processoId == processoId &&
        listEquals(other.tribunais, tribunais) &&
        listEquals(other.especies, especies);
  }

  @override
  int get hashCode => Object.hash(
        processoId,
        Object.hashAll(tribunais),
        Object.hashAll(especies),
      );
}

final processPipelineRemoteDataSourceProvider =
    Provider<ProcessPipelineRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ProcessPipelineRemoteDataSource(apiClient.dio);
});

final processPipelineRepositoryProvider = Provider<ProcessPipelineRepository>((
  ref,
) {
  final dataSource = ref.read(processPipelineRemoteDataSourceProvider);
  return ProcessPipelineRepositoryImpl(dataSource);
});

final processPipelineUseCaseProvider = Provider<ProcessPipelineUseCase>((ref) {
  final repository = ref.read(processPipelineRepositoryProvider);
  return ProcessPipelineUseCase(repository);
});

final processPipelineStreamProvider = StreamProvider.family<
    PrecedentStreamPipelineEvent,
    ProcessPipelineParams>((
  ref,
  params,
) {
  final useCase = ref.read(processPipelineUseCaseProvider);
  return useCase.call(params.processoId, params.tribunais, params.especies);
});

final processPipelineCancelProvider =
    Provider.family<VoidCallback, int>((ref, processoId) {
  final repository = ref.read(processPipelineRepositoryProvider);
  return () {
    repository.cancelStream(processoId);
  };
});

final processPipelineCancelAllProvider = Provider<VoidCallback>((ref) {
  final repository = ref.read(processPipelineRepositoryProvider);
  return () {
    repository.cancelAll();
  };
});

final analysisProcessViewModelProvider = StateNotifierProvider.autoDispose
    .family<AnalysisProcessViewModel, AnalysisProcessState, AnalysisProcessState>(
  (ref, initialState) {
    return AnalysisProcessViewModel(initialState);
  },
);
