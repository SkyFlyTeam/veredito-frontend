import '../../../domain/entities/peticao.dart';

class PetitionUploadState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final Peticao? petition;

  final double uploadProgress;

  const PetitionUploadState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.uploadProgress = 0.0,
    this.petition,
  });

  PetitionUploadState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    double? uploadProgress,
    bool clearError = false,
    Peticao? petition,
  }) {
    return PetitionUploadState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      petition: petition ?? this.petition,
    );
  }
}
