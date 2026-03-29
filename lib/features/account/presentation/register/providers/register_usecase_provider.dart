import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/user_remote_data_source.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../domain/use_cases/register_usecase.dart';
import '../view_models/register_state.dart';
import '../view_models/register_view_model.dart';

final registerViewModelProvider =
    StateNotifierProvider.autoDispose<RegisterViewModel, RegisterState>((ref) {
      final apiClient = ref.read(apiClientProvider);

      // Data Sources
      final userRemoteDataSource = UserRemoteDataSource(
        apiClient.dio,
        apiClient.secureStorage,
      );

      // Repositories
      final userRepository = UserRepositoryImpl(userRemoteDataSource);

      // Use Cases
      final registerUsecase = RegisterUsecase(userRepository);

      return RegisterViewModel(registerUsecase, ref);
    });
