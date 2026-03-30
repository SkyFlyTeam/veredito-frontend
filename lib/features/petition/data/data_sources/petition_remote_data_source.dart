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
        // total pode ser -1 quando o servidor não reporta Content-Length.
        // Nesse caso ignoramos: a barra ficará indeterminada até a resposta.
        if (total > 0) onProgress?.call((sent / total).clamp(0.0, 0.99));
      },
    );
    
    onProgress?.call(1.0);
  }
}
