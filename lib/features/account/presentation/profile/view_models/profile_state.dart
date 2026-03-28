import '../../../domain/entities/user.dart';

class ProfileState {
  final User? user;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  final int resetCount;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
    this.resetCount = 0,
  });

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    int? resetCount,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
      resetCount: resetCount ?? this.resetCount,
    );
  }
}
