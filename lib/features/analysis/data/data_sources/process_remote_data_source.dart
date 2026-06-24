
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      debugPrint('Uploading processo juridico: ${file.path}, size: ${await file.length()} bytes');
      if (file.path.contains('Documento')) {
        debugPrint('Simulando upload de processo juridico: ${file.path}');
        return ProcessoJuridico(
          id: int.tryParse(dotenv.env['MOCKED_PROCESS_ID'] ?? '1'),
          caminhoArquivo: 'https://example.com/Documento público.pdf',
          createdAt: DateTime.now(),
          instancia: instancia,
          classeProcessual: classeProcessual,
          areaDireito: areaDireito,
          tribunalPrecedenteId: tribunalPrecedenteId,
        );
      }

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

  Future<List<int>> generateMinutaSentenca({
    required int processoId,
    required String dispositivo,
    required List<int> precedentesSugeridos,
  }) async {
    try {
      final response = await dio.post<List<int>>(
        '/processo/minuta-sentenca',
        data: {
          'processo_id': processoId,
          'dispositivo': dispositivo,
          'precedentesSugeridos': precedentesSugeridos,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept':
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          },
        ),
      );

      final bytes = response.data;
      if (bytes == null) {
        throw Exception('Empty response when generating minuta de sentenca.');
      }

      return bytes;
    } catch (e) {
      throw Exception('Failed to generate minuta de sentenca: $e');
    }
  }
}