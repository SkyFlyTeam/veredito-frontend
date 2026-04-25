import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/pipeline_event_model.dart';

class PipelineStreamDataSource {
  final Dio dio;

  PipelineStreamDataSource(this.dio);

  Stream<PipelineEvent> streamPipeline(int peticaoId) async* {
    try {
      debugPrint('SSE DataSource: conectando em /peticao/$peticaoId/stream');
      final response = await dio.getUri<ResponseBody>(
        Uri.parse('/peticao/$peticaoId/stream'),
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
        ),
      );
      debugPrint('SSE DataSource: conexão estabelecida, lendo stream...');

      await for (final line in response.data!.stream
          .map((bytes) => utf8.decode(bytes))
          .transform(const LineSplitter())) {

        if (!line.startsWith('data:')) continue;

        final jsonString = line.substring(5).trim();
        if (jsonString.isEmpty) continue;

        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          debugPrint('SSE DataSource: evento parseado: ${json['stage']}');
          yield PipelineEvent.fromJson(json);
        } catch (e) {
          debugPrint('SSE DataSource: erro ao parsear: $e');
          rethrow;
        }
      }
      debugPrint('SSE DataSource: stream encerrado');
    } catch (e) {
      debugPrint('SSE DataSource: erro na conexão: $e');
      rethrow;
    }
  }
}