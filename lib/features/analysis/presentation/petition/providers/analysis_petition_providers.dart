import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/petition_pipeline_remote_data_source.dart';
import '../../../domain/entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../../../domain/entities/especie_precedente.dart';
import '../../../domain/entities/tribunal_precedente.dart';
import '../../../data/repositories/petition_pipeline_repository_impl.dart';
import '../../../domain/repositories/petition_pipeline_repository.dart';
import '../../../domain/use_cases/petition_pipeline_use_case.dart';
import '../view_models/analysis_petition_state.dart';
import '../view_models/analysis_petition_view_model.dart';

class PetitionPipelineParams {
  final int peticaoId;
  final List<TribunalPrecedente> tribunais;
  final List<EspeciePrecedente> especies;

  const PetitionPipelineParams({
    required this.peticaoId,
    required this.tribunais,
    required this.especies,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PetitionPipelineParams &&
        other.peticaoId == peticaoId &&
        listEquals(other.tribunais, tribunais) &&
        listEquals(other.especies, especies);
  }

  @override
  int get hashCode => Object.hash(
        peticaoId,
        Object.hashAll(tribunais),
        Object.hashAll(especies),
      );
}

final petitionPipelineRemoteDataSourceProvider =
    Provider<PetitionPipelineRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PetitionPipelineRemoteDataSource(apiClient.dio);
});

final petitionPipelineRepositoryProvider = Provider<PetitionPipelineRepository>((
  ref,
) {
  final dataSource = ref.read(petitionPipelineRemoteDataSourceProvider);
  return PetitionPipelineRepositoryImpl(dataSource);
});

final petitionPipelineUseCaseProvider = Provider<PetitionPipelineUseCase>((
  ref,
) {
  final repository = ref.read(petitionPipelineRepositoryProvider);
  return PetitionPipelineUseCase(repository);
});

final petitionPipelineStreamProvider = StreamProvider.family<
    PrecedentStreamPipelineEvent,
    PetitionPipelineParams>((
  ref,
  params,
) {
  final useCase = ref.read(petitionPipelineUseCaseProvider);
  return useCase.call(params.peticaoId, params.tribunais, params.especies);
});

final petitionPipelineCancelProvider =
    Provider.family<VoidCallback, int>((ref, petitionId) {
  final repository = ref.read(petitionPipelineRepositoryProvider);
  return () {
    repository.cancelStream(petitionId);
  };
});

final petitionPipelineCancelAllProvider = Provider<VoidCallback>((ref) {
  final repository = ref.read(petitionPipelineRepositoryProvider);
  return () {
    repository.cancelAll();
  };
});

final analysisPetitionViewModelProvider = StateNotifierProvider.autoDispose
    .family<AnalysisPetitionViewModel, AnalysisPetitionState,
        AnalysisPetitionState>((ref, initialState) {
  return AnalysisPetitionViewModel(initialState);
});
