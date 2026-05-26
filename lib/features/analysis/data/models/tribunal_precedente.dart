import '../../domain/entities/tribunal_precedente.dart' as entity;

class TribunalPrecedente {
  final int id;
  final String nome;
  final String sigla;

  TribunalPrecedente({
    required this.id,
    required this.nome,
    required this.sigla,
  });

  factory TribunalPrecedente.fromJson(Map<String, dynamic> json) {
    return TribunalPrecedente(
      id: json['id'] as int,
      nome: json['nome'] as String,
      sigla: json['sigla'] as String,
    );
  }

  entity.TribunalPrecedente toEntity() {
    return entity.TribunalPrecedente(id: id, nome: nome, sigla: sigla);
  }
}
