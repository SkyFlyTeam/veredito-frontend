import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../models/legal_case_model.dart';

class LegalCaseRemoteDataSource {
  final Dio dio;

  LegalCaseRemoteDataSource(this.dio);

  Future<LegalCaseModel> create({
    required String areaDireito,
    required String pedidosPrincipais,
    required String tesePretendida,
    required String contextoFaticoFundamentos,
    required String uf,
    int? tribunalPrecedenteId,
    required List<Map<String, dynamic>> files,
  }) async {
    final formData = FormData();

    formData.fields.addAll([
      MapEntry('area_direito', areaDireito),
      MapEntry('pedidos_principais', pedidosPrincipais),
      MapEntry('tese_pretendida', tesePretendida),
      MapEntry('contexto_fatico_fundamentos', contextoFaticoFundamentos),
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

  Future<void> updateSecao({
    required int legalCaseId,
    required int secaoId,
    required String conteudo,
  }) async {
    await dio.patch(
      '/caso-juridico/$legalCaseId/$secaoId',
      data: {'conteudo': conteudo},
    );
  }

  Future<Uint8List> downloadPeticao({
    required int legalCaseId,
  }) async {
    final response = await dio.get<List<int>>(
      '/caso-juridico/$legalCaseId/download-peticao',
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (_) => true,
      ),
    );

    final statusCode = response.statusCode ?? 0;
    final body = response.data;
    if (statusCode != 200 || body == null || body.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Download peticao falhou (status: $statusCode).',
        type: DioExceptionType.badResponse,
      );
    }

    return Uint8List.fromList(body);
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
