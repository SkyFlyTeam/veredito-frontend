import '../../domain/entities/status_precedente.dart' as entity;

class StatusPrecedente {
  final int? id;
  final String nome;

  StatusPrecedente({this.id, required this.nome});

  factory StatusPrecedente.fromJson(Map<String, dynamic> json) {
    return StatusPrecedente(
      id: json['id'] as int?,
      nome: json['nome'] as String,
    );
  }

  entity.StatusPrecedente toEntity() {
    return entity.StatusPrecedente(
      id: id ?? 0,
      nome: nome,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
    };
  }
}
