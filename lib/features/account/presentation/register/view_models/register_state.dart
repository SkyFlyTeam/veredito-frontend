class RegisterState {
  final bool isLoading;
  final String? error;

  const RegisterState({this.isLoading = false, this.error});

  RegisterState copyWith({bool? isLoading, String? error}) {
    return RegisterState(isLoading: isLoading ?? this.isLoading, error: error);
  }
}
