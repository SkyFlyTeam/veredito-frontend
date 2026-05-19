import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/user_remote_data_source.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/use_cases/register_usecase.dart';
import '../view_models/register_state.dart';
import '../view_models/register_view_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final userRemoteDataSource = UserRemoteDataSource(
    apiClient.dio,
    apiClient.publicDio,
    apiClient.secureStorage,
  );
  return UserRepositoryImpl(userRemoteDataSource);
});

final accessLevelsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  final levels = await repository.getAccessLevels();
  return levels.where((level) => level['nome'].toString().toLowerCase() != 'superuser').toList();
});

final registerViewModelProvider =
    StateNotifierProvider.autoDispose<RegisterViewModel, RegisterState>((ref) {
      final userRepository = ref.watch(userRepositoryProvider);
      final registerUsecase = RegisterUsecase(userRepository);

      return RegisterViewModel(registerUsecase, ref);
    });
