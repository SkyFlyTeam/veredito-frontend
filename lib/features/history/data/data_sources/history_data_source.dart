import 'package:dio/dio.dart';

import '../models/history_model.dart';
import '../../../precedent/data/models/precedent_suggested_model.dart';

class HistoryDataSource {
  final Dio dio;

  HistoryDataSource(this.dio);

  Future<List<AnalysisHistoryModel>> getAll() async {
    final response = await dio.get(
      '/peticao/historico',
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final List<dynamic> data =
        response.data is List ? response.data as List : [];

    return data
        .whereType<Map>()
        .map((item) => AnalysisHistoryModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  Future<List<PrecedentSuggestedModel>> getByPeticao(int peticaoId) async {
    final response = await dio.get(
      '/precedente-sugerido/por-peticao/$peticaoId',
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final List<dynamic> data =
        response.data is List ? response.data as List : [];

    return data
        .whereType<Map>()
        .map((item) => PrecedentSuggestedModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }
}