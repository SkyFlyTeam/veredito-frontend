import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/pipeline_event_model.dart';

class PipelineStreamDataSource {
  final Dio dio;
  final Map<int, CancelToken> _cancelTokens = {};

  PipelineStreamDataSource(this.dio);

  Stream<PipelineEvent> streamPipeline(int peticaoId) async* {
    try {
      final cancelToken = CancelToken();
      _cancelTokens[peticaoId] = cancelToken;

      debugPrint('SSE DataSource: conectando em /peticao/$peticaoId/stream');
      final response = await dio.getUri<ResponseBody>(
        Uri.parse('/peticao/$peticaoId/stream'),
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream', 'Cache-Control': 'no-cache'},
        ),
        cancelToken: cancelToken,
      );
      debugPrint('SSE DataSource: conexão estabelecida, lendo stream...');

      await for (final line
          in response.data!.stream
              .map<List<int>>((bytes) => bytes)
              .transform(utf8.decoder)
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        debugPrint('SSE DataSource: stream cancelado pelo usuário');
      } else {
        debugPrint('SSE DataSource: erro na conexão: $e');
        rethrow;
      }
    } catch (e) {
      debugPrint('SSE DataSource: erro na conexão: $e');
      rethrow;
    } finally {
      _cancelTokens.remove(peticaoId);
    }
  }

  void cancelStream(int peticaoId) {
    final cancelToken = _cancelTokens[peticaoId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      debugPrint('SSE DataSource: cancelando stream de $peticaoId');
      cancelToken.cancel();
    }
  }

  void cancelAll() {
    debugPrint('SSE DataSource: cancelando todos os streams');
    for (final token in _cancelTokens.values) {
      if (!token.isCancelled) {
        token.cancel();
      }
    }
    _cancelTokens.clear();
  }
}
