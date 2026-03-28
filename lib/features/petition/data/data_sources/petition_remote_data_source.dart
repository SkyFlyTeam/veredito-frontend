import 'package:dio/dio.dart';

class PetitionRemoteDataSource {
  final Dio _dio;

  const PetitionRemoteDataSource(this._dio);

  /// Sends [bytes] as a multipart/form-data POST to /peticao/upload.
  /// [fileName] must include the extension (e.g. "peticao.pdf").
  Future<void> uploadPetition(String fileName, List<int> bytes) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    await _dio.post('/peticao/upload', data: formData);
  }
}
