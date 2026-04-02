import 'package:dio/dio.dart';

import '../../../petition/domain/entities/peticao.dart';
import '../models/analyze_petition_response_model.dart';
import '../models/precedent_model.dart';
import '../models/precedent_suggested_model.dart';

class PrecedentRemoteDataSource {
  final Dio dio;

  PrecedentRemoteDataSource(this.dio);

  Future<List<PrecedentSuggestedModel>> getSuggestedPrecedents() async {
    final response = await dio.get('precedente-sugerido');

    return _extractList(response.data)
        .map((item) => PrecedentSuggestedModel.fromJson(item))
        .toList();
  }

  Future<PrecedentSuggestedModel?> getSuggestedPrecedentById(int id) async {
    final response = await dio.get('precedente-sugerido/$id');
    final data = _extractObject(response.data);

    if (data == null) {
      return null;
    }

    return PrecedentSuggestedModel.fromJson(data);
  }

  Future<List<PrecedentModel>> getPrecedents() async {
    final response = await dio.get('precedente');

    return _extractList(response.data)
        .map((item) => PrecedentModel.fromJson(item))
        .toList();
  }

  Future<PrecedentModel?> getPrecedentById(int id) async {
    final response = await dio.get('precedente/$id');
    final data = _extractObject(response.data);

    if (data == null) {
      return null;
    }

    return PrecedentModel.fromJson(data);
  }

  Future<AnalyzePetitionResponseModel> analyzePetition(Peticao peticao) async {
    final response = await dio.post('/peticao/${peticao.id}/analisar');
    final data = _extractObject(response.data) ?? const <String, dynamic>{};
    return AnalyzePetitionResponseModel.fromJson(data);
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final nestedData = data['data'];
      if (nestedData is List) {
        return nestedData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      final items = data['items'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
  }

  Map<String, dynamic>? _extractObject(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }

    return null;
  }
}
