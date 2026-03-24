import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';

class ProfileState {
  final User? user;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
    );
  }
}
