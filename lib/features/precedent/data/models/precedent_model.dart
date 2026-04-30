import '../../domain/entities/precedent.dart';

class PrecedentModel {
  final int id;
  final String numeroRegistro;
  final String? tese;
  final String? questao;
  final DateTime? ultimaAtualizacao;
  final String? teseVetor;
  final String? questaoVetor;
  final String? tribunalNome;
  final String? tribunalSigla;
  final String? statusNome;
  final String? especieNome;
  final String? especieSigla;

  PrecedentModel({
    required this.id,
    required this.numeroRegistro,
    this.tese,
    this.questao,
    required this.ultimaAtualizacao,
    this.teseVetor,
    this.questaoVetor,
    this.tribunalNome,
    this.tribunalSigla,
    this.statusNome,
    this.especieNome,
    this.especieSigla,
  });

  factory PrecedentModel.fromJson(Map<String, dynamic> json) {
    final tribunal = _asMap(json['tribunal']);
    final status = _asMap(json['status']);
    final especie = _asMap(json['especie']);
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
      tribunalNome: tribunal?['nome']?.toString(),
      tribunalSigla: tribunal?['sigla']?.toString(),
      statusNome: status?['nome']?.toString(),
      especieNome: especie?['nome']?.toString(),
      especieSigla: especie?['sigla']?.toString(),
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
      tribunalNome: entity.tribunalNome,
      tribunalSigla: entity.tribunalSigla,
      statusNome: entity.statusNome,
      especieNome: entity.especieNome,
      especieSigla: entity.especieSigla,
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
      tribunalNome: tribunalNome,
      tribunalSigla: tribunalSigla,
      statusNome: statusNome,
      especieNome: especieNome,
      especieSigla: especieSigla,
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
      'tribunal': {'nome': tribunalNome, 'sigla': tribunalSigla},
      'status': {'nome': statusNome},
      'especie': {'nome': especieNome, 'sigla': especieSigla},
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
