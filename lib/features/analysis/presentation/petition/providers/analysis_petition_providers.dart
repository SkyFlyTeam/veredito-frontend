import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/petition_pipeline_remote_data_source.dart';
import '../../../domain/entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../../../data/repositories/petition_pipeline_repository_impl.dart';
import '../../../domain/repositories/petition_pipeline_repository.dart';
import '../../../domain/use_cases/petition_pipeline_use_case.dart';
import '../view_models/analysis_petition_state.dart';
import '../view_models/analysis_petition_view_model.dart';

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

final petitionPipelineStreamProvider =
    StreamProvider.family<PrecedentStreamPipelineEvent, int>((
  ref,
  petitionId,
) {
  final useCase = ref.read(petitionPipelineUseCaseProvider);
  return useCase.call(petitionId);
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
