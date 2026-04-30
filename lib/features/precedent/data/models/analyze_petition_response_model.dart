import '../../domain/entities/analyze_petition_result.dart';
import 'precedent_suggested_model.dart';

class AnalyzePetitionResponseModel {
  final int peticaoId;
  final String? resumo;
  final List<PrecedentSuggestedModel> precedentes;

  const AnalyzePetitionResponseModel({
    required this.peticaoId,
    required this.resumo,
    required this.precedentes,
  });

  factory AnalyzePetitionResponseModel.fromJson(Map<String, dynamic> json) {
    final payload = _resolvePayload(json);
    final rawResumo = payload['resumo']?.toString().trim() ?? '';
    final rawPrecedentes = payload['precedentes'];

    return AnalyzePetitionResponseModel(
      peticaoId:
          _toInt(payload['peticaoId']) ?? _toInt(payload['peticao_id']) ?? 0,
      resumo: rawResumo.isEmpty ? null : rawResumo,
      precedentes: _extractList(
        rawPrecedentes,
      ).map(PrecedentSuggestedModel.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'peticaoId': peticaoId,
      'resumo': resumo,
      'precedentes': precedentes.map((item) => item.toJson()).toList(),
    };
  }

  AnalyzePetitionResult toEntity() {
    return AnalyzePetitionResult(
      petitionId: peticaoId,
      summary: resumo,
      suggestions: precedentes.map((item) => item.toEntity()).toList(),
    );
  }

  static Map<String, dynamic> _resolvePayload(Map<String, dynamic> json) {
    final nestedData = json['data'];
    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }

    if (nestedData is Map) {
      return Map<String, dynamic>.from(nestedData);
    }

    return json;
  }

  static List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const [];
  }

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt();
    }

    return int.tryParse(value.toString()) ??
        double.tryParse(value.toString())?.toInt();
  }
}
