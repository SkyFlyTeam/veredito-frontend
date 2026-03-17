import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/auth_data_remote_source.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/use_cases/login_usecase.dart';
import '../view_models/login_view_model.dart';
import '../view_models/login_state.dart';

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
      final apiClient = ref.read(apiClientProvider);
      final authRemoteDataSource = AuthRemoteDataSource(apiClient.dio);
      final authRepository = AuthRepositoryImpl(authRemoteDataSource);
      final loginUseCase = LoginUsecase(authRepository);
      return LoginViewModel(loginUseCase);
    });
