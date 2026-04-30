import '../../domain/entities/peticao.dart';

class PeticaoModel {
  final int id;
  final String caminhoArquivo;
  final String? resumo;
  final DateTime createdAt;
  final int usuarioId;

  const PeticaoModel({
    required this.id,
    required this.caminhoArquivo,
    this.resumo,
    required this.createdAt,
    required this.usuarioId,
  });

  factory PeticaoModel.fromJson(Map<String, dynamic> json) {
    return PeticaoModel(
      id: json['id'] as int,
      caminhoArquivo: json['caminhoArquivo'] as String,
      resumo: json['resumo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      usuarioId: json['usuarioId'] as int,
    );
  }

  Peticao toEntity() => Peticao(
    id: id,
    caminhoArquivo: caminhoArquivo,
    resumo: resumo,
    createdAt: createdAt,
    usuarioId: usuarioId,
  );
}
