import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/user_remote_data_source.dart';
import '../../../data/data_sources/auth_data_remote_source.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/use_cases/get_user_usecase.dart';
import '../../../domain/use_cases/update_user_usecase.dart';
import '../../../domain/use_cases/logout_usecase.dart';
import '../view_models/profile_view_model.dart';
import '../view_models/profile_state.dart';

final profileViewModelProvider =
    StateNotifierProvider.autoDispose<ProfileViewModel, ProfileState>((ref) {
      final apiClient = ref.read(apiClientProvider);

      // Data Sources
      final userRemoteDataSource = UserRemoteDataSource(
        apiClient.dio,
        apiClient.publicDio,
        apiClient.secureStorage,
      );
      final authRemoteDataSource = AuthRemoteDataSource(
        apiClient.dio,
        apiClient.secureStorage,
      );

      // Repositories
      final userRepository = UserRepositoryImpl(userRemoteDataSource);
      final authRepository = AuthRepositoryImpl(
        authRemoteDataSource,
        apiClient.secureStorage,
      );

      // Use Cases
      final getUserUseCase = GetUserUseCase(userRepository);
      final updateUserUseCase = UpdateUserUseCase(userRepository);
      final logoutUseCase = LogoutUseCase(authRepository);

      return ProfileViewModel(
        getUserUseCase: getUserUseCase,
        updateUserUseCase: updateUserUseCase,
        logoutUseCase: logoutUseCase,
        ref: ref,
      );
    });
