import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cookiecutter/core/network/api_client_provider.dart';
import 'package:flutter_cookiecutter/features/account/data/data_sources/auth_data_remote_source.dart';
import 'package:flutter_cookiecutter/features/account/data/repositories/auth_repository_impl.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/login_usecase.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/view_models/login_view_model.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/view_models/login_state.dart';

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
      final apiClient = ref.read(apiClientProvider);
      final authRemoteDataSource = AuthRemoteDataSource(
        apiClient.dio,
        apiClient.secureStorage,
      );
      final authRepository = AuthRepositoryImpl(authRemoteDataSource);
      final loginUseCase = LoginUsecase(authRepository);
      return LoginViewModel(loginUseCase, ref);
    });
