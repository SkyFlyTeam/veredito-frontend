import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/errors/api_exception.dart';
import '../../../domain/use_cases/login_usecase.dart';
import '../providers/session_provider.dart';
import 'login_state.dart';

class LoginViewModel extends StateNotifier<LoginState> {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final LoginUsecase loginUseCase;
  final Ref _ref;

  LoginViewModel(this.loginUseCase, this._ref) : super(const LoginState());

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
      final user = await loginUseCase.execute(normalizedEmail, password);
      _ref.read(sessionProvider.notifier).setUser(user);
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        state = state.copyWith(
          isLoading: false,
          error: 'Email ou senha incorretos.',
        );
        return;
      }
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Falha no login.');
    }
  }
}
