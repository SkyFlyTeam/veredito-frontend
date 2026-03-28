class PetitionUploadState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  /// Reserved for VER-16 progress bar widget integration.
  final double uploadProgress;

  const PetitionUploadState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.uploadProgress = 0.0,
  });

  PetitionUploadState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    double? uploadProgress,
    bool clearError = false,
  }) {
    return PetitionUploadState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}
