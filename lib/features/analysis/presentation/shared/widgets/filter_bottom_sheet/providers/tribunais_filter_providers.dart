import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../core/network/api_client_provider.dart';
import '../../../../../data/data_sources/filters_remote_data_source.dart';
import '../../../../../data/repositories/filters_repository_impl.dart';
import '../../../../../domain/repositories/filters_repository.dart';
import '../../../../../domain/use_cases/filters_use_case.dart';
import '../view_models/especies_filter_state.dart';
import '../view_models/especies_filter_view_model.dart';
import '../view_models/tribunais_filter_state.dart';
import '../view_models/tribunais_filter_view_model.dart';

final filtersRemoteDataSourceProvider = Provider<FiltersRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return FiltersRemoteDataSource(dio: apiClient.dio);
});

final filtersRepositoryProvider = Provider<FiltersRepository>((ref) {
  final dataSource = ref.read(filtersRemoteDataSourceProvider);
  return FiltersRepositoryImpl(dataSource);
});

final filtersUseCaseProvider = Provider<FiltersUseCase>((ref) {
  final repository = ref.read(filtersRepositoryProvider);
  return FiltersUseCase(repository);
});

final tribunaisFilterViewModelProvider =
    StateNotifierProvider.autoDispose<TribunaisFilterViewModel, TribunaisFilterState>((
      ref,
    ) {
      final useCase = ref.read(filtersUseCaseProvider);
      return TribunaisFilterViewModel(useCase);
    });

final especiesFilterViewModelProvider =
    StateNotifierProvider.autoDispose<EspeciesFilterViewModel, EspeciesFilterState>((
      ref,
    ) {
      final useCase = ref.read(filtersUseCaseProvider);
      return EspeciesFilterViewModel(useCase);
    });
