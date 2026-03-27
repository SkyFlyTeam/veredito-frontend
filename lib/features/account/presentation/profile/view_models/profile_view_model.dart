import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/get_user_usecase.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/update_user_usecase.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/logout_usecase.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/providers/session_provider.dart';
import 'package:flutter_cookiecutter/features/account/presentation/profile/view_models/profile_state.dart';

class ProfileViewModel extends StateNotifier<ProfileState> {
  final GetUserUseCase getUserUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final LogoutUseCase logoutUseCase;
  final AutoDisposeRef ref;

  ProfileViewModel({
    required this.getUserUseCase,
    required this.updateUserUseCase,
    required this.logoutUseCase,
    required this.ref,
  }) : super(const ProfileState());

  Future<void> loadProfile(int userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await getUserUseCase.execute(userId);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      // Fallback to authProvider if fetch fails (due to permissions or backend missing)
      final currentUser = ref.read(sessionProvider);
      if (currentUser != null) {
        state = state.copyWith(user: currentUser, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: "Erro ao carregar perfil. Faça login novamente.");
      }
    }
  }

  Future<void> updateProfile(int userId, String name, String email, String? password) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);
    try {
    if (name.trim().isEmpty) {
      state = state.copyWith(isSaving: false, error: "O campo Nome é obrigatório");
      return;
    }

    if (email.trim().isEmpty) {
      state = state.copyWith(isSaving: false, error: "O campo Email é obrigatório");
      return;
    }

    final nameParts = name.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      final data = {
        'nome': firstName,
        'sobrenome': lastName,
        'email': email,
      };
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }
      
      final updatedUser = await updateUserUseCase.execute(userId, data);
      
      // Update local state and global auth provider
      state = state.copyWith(
        user: updatedUser,
        isSaving: false, 
        successMessage: "Perfil atualizado com sucesso!"
      );
      ref.read(sessionProvider.notifier).setUser(updatedUser);
    } catch (e) {
      String errorMessage = "Erro ao salvar as alterações. Verifique os campos novamente";
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          errorMessage = e.response?.data['message'] ?? "Email já cadastrado";
        }
      }
      state = state.copyWith(isSaving: false, error: errorMessage);
    }
  }

  void resetState() {
    state = state.copyWith(
      error: null,
      successMessage: null,
      isSaving: false,
    );
  }

  Future<void> logout() async {
    try {
      await logoutUseCase.execute();
      await ref.read(sessionProvider.notifier).clearUser();
    } catch (e) {
      state = state.copyWith(error: "Erro ao sair");
    }
  }
}
