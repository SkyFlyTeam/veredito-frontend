import '../../domain/entities/precedent.dart';
import 'package:flutter/foundation.dart';

import 'especie_precedente.dart';
import 'status_precedente.dart';
import 'tribunal_precedente.dart';

class Precedente {
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

  Precedente({
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
  });

  factory Precedente.fromJson(Map<String, dynamic> json) {
    final tribunal = _asMap(json['tribunal']) ??
      ((json['tribunal_id'] != null ||
          json['tribunal_nome'] != null ||
          json['tribunal_sigla'] != null)
        ? {
          'id': json['tribunal_id'],
          'nome': json['tribunal_nome'],
          'sigla': json['tribunal_sigla'],
          }
        : null);
    final status = _asMap(json['status']) ??
      ((json['status_id'] != null || json['status_nome'] != null)
        ? {'id': json['status_id'], 'nome': json['status_nome']}
        : null);
    final especie = _asMap(json['especie']) ??
      ((json['especie_id'] != null ||
          json['especie_nome'] != null ||
          json['especie_sigla'] != null)
        ? {
          'id': json['especie_id'],
          'nome': json['especie_nome'],
          'sigla': json['especie_sigla'],
          }
        : null);
    final ultimaAtualizacao =
        json['ultima_atualizacao']?.toString().trim() ?? '';

    return Precedente(
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
      tribunal: tribunal != null
          ? TribunalPrecedente.fromJson(tribunal!)
          : null,
      status: status != null ? StatusPrecedente.fromJson(status!) : null,
      especie: especie != null ? EspeciePrecedente.fromJson(especie!) : null,
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
      tribunal: tribunal?.toEntity(),
      status: status?.toEntity(),
      especie: especie?.toEntity(),
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
