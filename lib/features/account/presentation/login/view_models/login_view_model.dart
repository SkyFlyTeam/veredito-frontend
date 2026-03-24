import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/use_cases/login_usecase.dart';
import 'login_state.dart';

class LoginViewModel extends StateNotifier<LoginState> {
  static const _minimumLoadingTime = Duration(seconds: 5);
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final LoginUsecase loginUseCase;

  LoginViewModel(this.loginUseCase) : super(const LoginState());

  Future<void> login(String email, String password) async {
    final normalizedEmail = email.trim();
    final normalizedPassword = password.trim();

    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) {
      state = state.copyWith(error: 'Email ou Senha incorretos.');
      return;
    }

    if (!_emailRegex.hasMatch(normalizedEmail)) {
      state = state.copyWith(error: 'Email ou senha incorretos.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.wait([
        loginUseCase.execute(normalizedEmail, password),
        Future.delayed(_minimumLoadingTime),
      ]);

      state = state.copyWith(isLoading: false);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        state = state.copyWith(
          isLoading: false,
          error: 'Email ou senha incorretos.',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Falha ao conectar com o servidor.',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Falha no login.');
    }
  }
}
