import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/get_user_usecase.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/update_user_usecase.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/logout_usecase.dart';
import 'package:flutter_cookiecutter/features/account/presentation/auth_provider.dart';
import 'package:flutter_cookiecutter/features/account/presentation/profile/view_models/profile_state.dart';

class ProfileViewModel extends StateNotifier<ProfileState> {
  final GetUserUseCase getUserUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final LogoutUseCase logoutUseCase;
  final Ref ref;

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
      state = state.copyWith(isSaving: false, error: "Erro ao salvar as alterações. Verifique os campos novamente");
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase.execute();
    } catch (e) {
      state = state.copyWith(error: "Erro ao sair");
    }
  }
}
