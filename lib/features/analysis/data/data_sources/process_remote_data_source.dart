
import 'dart:io';

import 'package:dio/dio.dart';

import '../models/processo_juridico.dart';

class ProcessRemoteDataSource {
  final Dio dio;

  ProcessRemoteDataSource({required this.dio});

  Future<ProcessoJuridico> createProcessoJuridico({
    required File file,
    required int instancia,
    required String classeProcessual,
    required String areaDireito,
    required int tribunalPrecedenteId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.uri.pathSegments.isNotEmpty
              ? file.uri.pathSegments.last
              : 'processo_juridico',
        ),
        'instancia': instancia,
        'classe_processual': classeProcessual,
        'area_direito': areaDireito,
        'tribunal_precedente': tribunalPrecedenteId,
      });

      final response = await dio.post(
        '/processo',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return ProcessoJuridico.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create processo juridico: $e');
    }
  }
}