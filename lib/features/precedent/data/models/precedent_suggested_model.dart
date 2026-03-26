import '../../domain/entities/precedent_suggested.dart';
import 'precedent_model.dart';

class PrecedentSuggestedModel {
  final int id;
  final int petitionId;
  final int precedentId;
  final double percentualSimilaridade;
  final int classificacao;
  final String? sinteseExplicativa;
  final PrecedentModel? precedent;

  PrecedentSuggestedModel({
    required this.id,
    required this.petitionId,
    required this.precedentId,
    required this.percentualSimilaridade,
    required this.classificacao,
    required this.sinteseExplicativa,
    this.precedent,
  });

  factory PrecedentSuggestedModel.fromJson(Map<String, dynamic> json) {
    final sinteseExplicativa =
        json['sintese_explicativa']?.toString().trim() ?? '';
    final petition = _asMap(json['peticao']);
    final precedent = _asMap(json['precedente']);

    return PrecedentSuggestedModel(
      id:
          (json['id'] as num?)?.toInt() ??
          int.tryParse(json['id']?.toString() ?? '') ??
          0,
      petitionId:
          (petition?['id'] as num?)?.toInt() ??
          (json['peticao_id'] as num?)?.toInt() ??
          (json['petition_id'] as num?)?.toInt() ??
          int.tryParse(
                petition?['id']?.toString() ??
                    json['peticao_id']?.toString() ??
                    json['petition_id']?.toString() ??
                    '',
              ) ??
          0,
      precedentId:
          (precedent?['id'] as num?)?.toInt() ??
          (json['precedente_id'] as num?)?.toInt() ??
          (json['precedent_id'] as num?)?.toInt() ??
          int.tryParse(
                precedent?['id']?.toString() ??
                    json['precedente_id']?.toString() ??
                    json['precedent_id']?.toString() ??
                    '',
              ) ??
          0,
      percentualSimilaridade:
          (json['percentual_similaridade'] as num?)?.toDouble() ??
          double.tryParse(json['percentual_similaridade']?.toString() ?? '') ??
          0,
      classificacao:
          (json['classificacao'] as num?)?.toInt() ??
          int.tryParse(json['classificacao']?.toString() ?? '') ??
          0,
      sinteseExplicativa:
          sinteseExplicativa.isEmpty ? null : sinteseExplicativa,
      precedent:
          precedent == null ? null : PrecedentModel.fromJson(precedent),
    );
  }

  factory PrecedentSuggestedModel.fromEntity(PrecedentSuggested entity) {
    return PrecedentSuggestedModel(
      id: entity.id,
      petitionId: entity.petitionId,
      precedentId: entity.precedentId,
      percentualSimilaridade: entity.percentualSimilaridade,
      classificacao: entity.classificacao,
      sinteseExplicativa: entity.sinteseExplicativa,
      precedent:
          entity.precedent == null
              ? null
              : PrecedentModel.fromEntity(entity.precedent!),
    );
  }

  PrecedentSuggested toEntity() {
    return PrecedentSuggested(
      id: id,
      petitionId: petitionId,
      precedentId: precedentId,
      percentualSimilaridade: percentualSimilaridade,
      classificacao: classificacao,
      sinteseExplicativa: sinteseExplicativa,
      precedent: precedent?.toEntity(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petition_id': petitionId,
      'precedent_id': precedentId,
      'percentual_similaridade': percentualSimilaridade,
      'classificacao': classificacao,
      'sintese_explicativa': sinteseExplicativa,
      'precedente': precedent?.toJson(),
    };
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return null;
}
