import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/use_cases/upload_petition_usecase.dart';
import 'petition_upload_state.dart';

class PetitionUploadViewModel extends StateNotifier<PetitionUploadState> {
  final UploadPetitionUsecase _uploadUsecase;

  PetitionUploadViewModel(this._uploadUsecase)
      : super(const PetitionUploadState());


  Future<void> upload(
    String fileName,
    List<int> bytes, {
    void Function(double)? onProgress,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      isSuccess: false,
      uploadProgress: 0.0,
    );

    try {
      final peticao = await _uploadUsecase.execute(fileName, bytes, onProgress: onProgress);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        uploadProgress: 1.0,
        petition: peticao,
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          'Erro ao enviar a petição. Tente novamente.';
      state = state.copyWith(isLoading: false, error: message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado. Tente novamente.',
      );
    }
  }
}
