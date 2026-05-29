import 'package:dio/dio.dart';
import '../models/legal_case_model.dart';

class LegalCaseRemoteDataSource {
  final Dio dio;

  LegalCaseRemoteDataSource(this.dio);

  Future<LegalCaseModel> create({
    required String areaDireito,
    required String pedidosPrincipais,
    required String tesePretendida,
    required String fatosEstruturados,
    required String fundamentosJuridicos,
    required String uf,
    int? tribunalPrecedenteId,
    required List<Map<String, dynamic>> files,
  }) async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('area_direito', areaDireito),
      MapEntry('pedidos_principais', pedidosPrincipais),
      MapEntry('tese_pretendida', tesePretendida),
      MapEntry('fatos_estruturados', fatosEstruturados),
      MapEntry('fundamentos_juridicos', fundamentosJuridicos),
      MapEntry('uf', uf),
      if (tribunalPrecedenteId != null)
        MapEntry('tribunalPrecedenteId', tribunalPrecedenteId.toString()),
    ]);

    for (final file in files) {
      final originalName = file['name'] as String;
      formData.files.add(
        MapEntry(
          'files',
          MultipartFile.fromBytes(
            file['bytes'] as List<int>,
            filename: _normalizeFileName(originalName),
          ),
        ),
      );
    }

    final response = await dio.post('/caso-juridico', data: formData);
    return LegalCaseModel.fromJson(response.data as Map<String, dynamic>);
  }

  String _normalizeFileName(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return fileName;
    }

    final baseName = fileName.substring(0, dotIndex);
    final extension = fileName.substring(dotIndex + 1).toLowerCase();
    return '$baseName.$extension';
  }
}
