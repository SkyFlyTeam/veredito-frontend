import 'package:dio/dio.dart';

class PetitionRemoteDataSource {
  final Dio _dio;

  const PetitionRemoteDataSource(this._dio);

  /// Sends [bytes] as a multipart/form-data POST to /peticao/upload.
  /// [fileName] must include the extension (e.g. "peticao.pdf").
  /// [onProgress] is called with values from 0.0 to 1.0 as bytes are sent.
  Future<void> uploadPetition(
    String fileName,
    List<int> bytes, {
    void Function(double)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    await _dio.post(
      '/peticao/upload',
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call((sent / total).clamp(0.0, 0.99));
      },
    );
    // Garante 100% somente após o servidor confirmar o recebimento (resposta HTTP).
    // onSendProgress para em ~99% enquanto o servidor processa; forçamos 1.0 aqui.
    onProgress?.call(1.0);
  }
}
