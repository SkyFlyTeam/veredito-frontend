import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/api_exception.dart';
import '../../../domain/use_cases/register_usecase.dart';
import 'register_state.dart';

class RegisterViewModel extends StateNotifier<RegisterState> {
  final RegisterUsecase registerUseCase;
  final Ref ref;

  RegisterViewModel(this.registerUseCase, this.ref) : super(const RegisterState());

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await registerUseCase.execute(name, email, password);

      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Ocorreu um erro ao registrar. Por favor, tente novamente.",
      );
    }
  }
}