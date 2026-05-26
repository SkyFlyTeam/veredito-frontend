
import '../../domain/entities/precedent.dart';

import 'especie_precedente.dart';
import 'status_precedente.dart';
import 'tribunal_precedente.dart';

class PrecedentModel {
  final int id;
  final String numeroRegistro;
  final String? tese;
  final String? questao;
  final DateTime? ultimaAtualizacao;
  final String? teseVetor;
  final String? questaoVetor;
  final TribunalPrecedente? tribunal;
  final EspeciePrecedente? especie;
  final StatusPrecedente? status;
  final double? similaridade;

  PrecedentModel({
    required this.id,
    required this.numeroRegistro,
    this.tese,
    this.questao,
    required this.ultimaAtualizacao,
    this.teseVetor,
    this.questaoVetor,
    this.tribunal,
    this.especie,
    this.status,
    this.similaridade,
  });

  factory PrecedentModel.fromJson(Map<String, dynamic> json) {
    final tribunal = json['tribunal'] ? _asMap(json['tribunal']) : {'id': json['tribunal_id'], 'nome': json['tribunal_nome'], 'sigla': json['tribunal_sigla']};
    final status = json['status'] ? _asMap(json['status']) : {'id': json['status_id'], 'nome': json['status_nome']};
    final especie = json['especie'] ? _asMap(json['especie']) : {'id': json['especie_id'], 'nome': json['especie_nome'], 'sigla': json['especie_sigla']};
    final ultimaAtualizacao =
        json['ultima_atualizacao']?.toString().trim() ?? '';



    return PrecedentModel(
      id:
          (json['id'] as num?)?.toInt() ??
          int.tryParse(json['id']?.toString() ?? '') ??
          0,
      numeroRegistro: json['numero_registro']?.toString() ?? '',
      tese: json['tese'] as String?,
      questao: json['questao'] as String?,
      ultimaAtualizacao: ultimaAtualizacao.isEmpty
          ? null
          : DateTime.tryParse(ultimaAtualizacao),
      teseVetor: json['tese_vetor'] as String?,
      questaoVetor: json['questao_vetor'] as String?,
      tribunal: tribunal != null ? TribunalPrecedente.fromJson(tribunal!) : null,
      status: status != null ? StatusPrecedente.fromJson(status!) : null,
      especie: especie != null ? EspeciePrecedente.fromJson(especie!) : null,
      similaridade: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory PrecedentModel.fromEntity(Precedent entity) {
    return PrecedentModel(
      id: entity.id,
      numeroRegistro: entity.numeroRegistro,
      tese: entity.tese,
      questao: entity.questao,
      ultimaAtualizacao: entity.ultimaAtualizacao,
      teseVetor: entity.teseVetor,
      questaoVetor: entity.questaoVetor,
      tribunal: entity.tribunal,
      status: entity.status,
      especie: entity.especie,
      similaridade: entity.similaridade,
    );
  }

  Precedent toEntity() {
    return Precedent(
      id: id,
      numeroRegistro: numeroRegistro,
      tese: tese,
      questao: questao,
      ultimaAtualizacao: ultimaAtualizacao,
      teseVetor: teseVetor,
      questaoVetor: questaoVetor,
      tribunal: tribunal,
      status: status,
      especie: especie,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_registro': numeroRegistro,
      'tese': tese,
      'ultima_atualizacao': ultimaAtualizacao?.toIso8601String(),
      'tese_vetor': teseVetor,
      'questao_vetor': questaoVetor,
      'tribunal': tribunal?.toJson(),
      'status': status?.toJson(),
      'especie': especie?.toJson(),
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

