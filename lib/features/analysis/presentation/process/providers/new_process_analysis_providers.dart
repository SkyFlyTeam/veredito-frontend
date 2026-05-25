import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/filters_remote_data_source.dart';
import '../../../data/data_sources/process_remote_data_source.dart';
import '../../../data/repositories/filters_repository_impl.dart';
import '../../../data/repositories/process_repository_impl.dart';
import '../../../domain/repositories/filters_repository.dart';
import '../../../domain/repositories/process_repository.dart';
import '../../../domain/use_cases/filters_use_case.dart';
import '../../../domain/use_cases/process_use_case.dart';
import '../view_models/new_process_analysis_state.dart';
import '../view_models/new_process_analysis_view_model.dart';

final processFiltersRemoteDataSourceProvider =
    Provider<FiltersRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return FiltersRemoteDataSource(dio: apiClient.dio);
});

final processFiltersRepositoryProvider = Provider<FiltersRepository>((ref) {
  final dataSource = ref.read(processFiltersRemoteDataSourceProvider);
  return FiltersRepositoryImpl(dataSource);
});

final processFiltersUseCaseProvider = Provider<FiltersUseCase>((ref) {
  final repository = ref.read(processFiltersRepositoryProvider);
  return FiltersUseCase(repository);
});

final processRemoteDataSourceProvider =
    Provider<ProcessRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ProcessRemoteDataSource(dio: apiClient.dio);
});

final processRepositoryProvider = Provider<ProcessRepository>((ref) {
  final dataSource = ref.read(processRemoteDataSourceProvider);
  return ProcessRepositoryImpl(remoteDataSource: dataSource);
});

final processUseCaseProvider = Provider<ProcessUseCase>((ref) {
  final repository = ref.read(processRepositoryProvider);
  return ProcessUseCase(repository: repository);
});

final newProcessAnalysisViewModelProvider = StateNotifierProvider.autoDispose<
    NewProcessAnalysisViewModel,
    NewProcessAnalysisState>((ref) {
  final filtersUseCase = ref.read(processFiltersUseCaseProvider);
  final processUseCase = ref.read(processUseCaseProvider);
  return NewProcessAnalysisViewModel(filtersUseCase, processUseCase);
});
