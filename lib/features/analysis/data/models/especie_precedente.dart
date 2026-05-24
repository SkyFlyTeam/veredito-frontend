import '../../domain/entities/especie_precedente.dart' as entity;

class EspeciePrecedente {
  final int id;
  final String nome;
  final String sigla;

  EspeciePrecedente({
    required this.id,
    required this.nome,
    required this.sigla,
  });

  factory EspeciePrecedente.fromJson(Map<String, dynamic> json) {
    return EspeciePrecedente(
      id: json['id'] as int,
      nome: json['nome'] as String,
      sigla: json['sigla'] as String,
    );
  }

  entity.EspeciePrecedente toEntity() {
    return entity.EspeciePrecedente(id: id, nome: nome, sigla: sigla);
  }
}
