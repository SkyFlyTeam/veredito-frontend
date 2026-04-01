import '../../../../core/utils/values_conversor.dart';
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
      id: valueToInt(json['id']) ?? 0,
      petitionId:
        valueToInt(petition?['id']) ??
        valueToInt(json['peticaoId']) ??
        valueToInt(json['peticao_id']) ??
        valueToInt(json['petition_id']) ??
        0,
      precedentId:
        valueToInt(precedent?['id']) ??
        valueToInt(json['precedenteId']) ??
        valueToInt(json['precedente_id']) ??
        valueToInt(json['precedent_id']) ??
        0,
      percentualSimilaridade: valueToDouble(json['percentual_similaridade']) ?? 0,
      classificacao: valueToInt(json['classificacao']) ?? 0,
      sinteseExplicativa: sinteseExplicativa.isEmpty
          ? null
          : sinteseExplicativa,
      precedent: precedent == null ? null : PrecedentModel.fromJson(precedent),
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
      precedent: entity.precedent == null
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
