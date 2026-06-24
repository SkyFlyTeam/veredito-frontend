import '../../domain/entities/peca.dart' as domain;

class Peca {
  final String nome;
  final int paginaInicial;
  final int paginaFinal;

  Peca({
    required this.nome,
    required this.paginaInicial,
    required this.paginaFinal,
  });

  factory Peca.fromJson(Map<String, dynamic> json) {
    return Peca(
      nome: json['name'] as String,
      paginaInicial: json['startPage'] as int,
      paginaFinal: (json['endPage'] as int?) ?? 45,
    );
  }

  domain.Peca toEntity() {
    return domain.Peca(
      nome: nome,
      paginaInicial: paginaInicial,
      paginaFinal: paginaFinal,
    );
  }
}