import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/use_cases/login_usecase.dart';
import 'login_state.dart';

class LoginViewModel extends StateNotifier<LoginState> {
  final LoginUsecase loginUseCase;

  LoginViewModel(this.loginUseCase) : super(const LoginState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await loginUseCase.execute(email, password);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Login failed");
    }
  }
}
