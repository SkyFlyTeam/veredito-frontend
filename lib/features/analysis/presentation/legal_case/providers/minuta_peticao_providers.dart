import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/legal_case_pipeline_remote_data_souce.dart';
import '../../../data/data_sources/legal_case_remote_data_source.dart';
import '../../../data/repositories/legal_case_pipeline_repository_impl.dart';
import '../../../data/repositories/legal_case_repository_impl.dart';
import '../../../domain/entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../../../domain/repositories/legal_case_pipeline_repository.dart';
import '../../../domain/repositories/legal_case_repository.dart';
import '../../../domain/use_cases/download_legal_case_peticao_use_case.dart';
import '../../../domain/use_cases/legal_case_pipeline_use_case.dart';
import '../../../domain/use_cases/update_legal_case_section_use_case.dart';
import '../view_models/minuta_peticao_state.dart';
import '../view_models/minuta_peticao_view_model.dart';

class LegalCasePipelineParams {
  final int legalCaseId;

  const LegalCasePipelineParams({required this.legalCaseId});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LegalCasePipelineParams &&
        other.legalCaseId == legalCaseId;
  }

  @override
  int get hashCode => legalCaseId.hashCode;
}

final legalCasePipelineRemoteDataSourceProvider =
    Provider<LegalCasePipelineRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return LegalCasePipelineRemoteDataSource(apiClient.dio);
});

final legalCasePipelineRepositoryProvider =
    Provider<LegalCasePipelineRepository>((ref) {
  final dataSource = ref.read(legalCasePipelineRemoteDataSourceProvider);
  return LegalCasePipelineRepositoryImpl(dataSource);
});

final legalCasePipelineUseCaseProvider =
    Provider<LegalCasePipelineUseCase>((ref) {
  final repository = ref.read(legalCasePipelineRepositoryProvider);
  return LegalCasePipelineUseCase(repository);
});

final legalCasePipelineStreamProvider = StreamProvider.family<
    PrecedentStreamPipelineEvent,
    LegalCasePipelineParams>((ref, params) {
  final useCase = ref.read(legalCasePipelineUseCaseProvider);
  return useCase.call(params.legalCaseId);
});

final legalCasePipelineCancelProvider =
    Provider.family<VoidCallback, int>((ref, legalCaseId) {
  final repository = ref.read(legalCasePipelineRepositoryProvider);
  return () {
    repository.cancelStream(legalCaseId);
  };
});

final legalCasePipelineCancelAllProvider = Provider<VoidCallback>((ref) {
  final repository = ref.read(legalCasePipelineRepositoryProvider);
  return () {
    repository.cancelAll();
  };
});

final legalCaseRemoteDataSourceProvider =
    Provider<LegalCaseRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return LegalCaseRemoteDataSource(apiClient.dio);
});

final legalCaseRepositoryProvider = Provider<LegalCaseRepository>((ref) {
  final dataSource = ref.read(legalCaseRemoteDataSourceProvider);
  return LegalCaseRepositoryImpl(dataSource);
});

final updateLegalCaseSectionUseCaseProvider =
    Provider<UpdateLegalCaseSectionUseCase>((ref) {
  final repository = ref.read(legalCaseRepositoryProvider);
  return UpdateLegalCaseSectionUseCase(repository);
});

final downloadLegalCasePeticaoUseCaseProvider =
    Provider<DownloadLegalCasePeticaoUseCase>((ref) {
  final repository = ref.read(legalCaseRepositoryProvider);
  return DownloadLegalCasePeticaoUseCase(repository);
});

final minutaPeticaoViewModelProvider = StateNotifierProvider.autoDispose
    .family<MinutaPeticaoViewModel, MinutaPeticaoState, MinutaPeticaoState>(
  (ref, initialState) {
    final useCase = ref.read(updateLegalCaseSectionUseCaseProvider);
    final downloadUseCase = ref.read(downloadLegalCasePeticaoUseCaseProvider);
    return MinutaPeticaoViewModel(initialState, useCase, downloadUseCase);
  },
);
