import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../analysis/data/data_sources/caso_juridico_remote_data_source.dart';
import '../../../../analysis/data/repositories/caso_juridico_repository_impl.dart';
import '../../../../analysis/domain/repositories/caso_juridico_repository.dart';
import '../../../../analysis/domain/use_cases/caso_juridico_use_case.dart';
import '../../../../../core/network/api_client_provider.dart';
import '../view_models/minuta_peticao_state.dart';
import '../view_models/minuta_peticao_view_model.dart';

final casoJuridicoRemoteDataSourceProvider =
    Provider<CasoJuridicoRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CasoJuridicoRemoteDataSource(dio: apiClient.dio);
});

final casoJuridicoRepositoryProvider = Provider<CasoJuridicoRepository>((ref) {
  final dataSource = ref.read(casoJuridicoRemoteDataSourceProvider);
  return CasoJuridicoRepositoryImpl(remoteDataSource: dataSource);
});

final casoJuridicoUseCaseProvider = Provider<CasoJuridicoUseCase>((ref) {
  final repository = ref.read(casoJuridicoRepositoryProvider);
  return CasoJuridicoUseCase(repository: repository);
});

final minutaPeticaoViewModelProvider = StateNotifierProvider.autoDispose
    .family<MinutaPeticaoViewModel, MinutaPeticaoState, MinutaPeticaoState>(
  (ref, initialState) {
    final useCase = ref.read(casoJuridicoUseCaseProvider);
    return MinutaPeticaoViewModel(useCase, initialState);
  },
);
