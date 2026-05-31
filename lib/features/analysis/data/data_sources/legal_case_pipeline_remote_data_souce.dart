import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/legal_case_stream_events/legal_case_stream_pipeline_event.dart';
import '../models/precedent_stream_events/precedent_stream_pipeline_event.dart';

class LegalCasePipelineRemoteDataSource {
  final Dio dio;
  final Map<int, CancelToken> _cancelTokens = {};

  LegalCasePipelineRemoteDataSource(this.dio);

  Stream<StreamPipelineEvent> streamPipeline(
    int legalCaseId
  ) async* {
    try {
      final cancelToken = CancelToken();
      _cancelTokens[legalCaseId] = cancelToken;

      debugPrint('SSE DataSource: conectando em /caso-juridico/$legalCaseId/stream');
      final response = await dio.postUri<ResponseBody>(
        Uri.parse('/caso-juridico/$legalCaseId/stream'),
        data: {
          'filtros': {
            'tribunais': [],
            'especies': [],
          },
        },
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
          yield LegalCaseStreamPipelineEvent.fromJson(json, 'casoJuridicoId');
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
      _cancelTokens.remove(legalCaseId);
    }
  }

  void cancelStream(int legalCaseId) {
    final cancelToken = _cancelTokens[legalCaseId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      debugPrint('SSE DataSource: cancelando stream de $legalCaseId');
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
