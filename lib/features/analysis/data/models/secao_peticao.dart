import '../../domain/entities/secao_peticao.dart' as entity;

class SecaoPeticao {
    final int id;
    final String titulo;
    final String conteudo;

    SecaoPeticao({
        required this.id,
        required this.titulo,
        required this.conteudo,
    });

    factory SecaoPeticao.fromJson(Map<String, dynamic> json) {
        return SecaoPeticao(
            id: json['id'] as int,
            titulo: json['titulo'] as String,
            conteudo: json['conteudo'] as String,
        );
    }

    entity.SecaoPeticao toEntity() {
        return entity.SecaoPeticao(
            id: id,
            titulo: titulo,
            conteudo: conteudo,
        );
    }
}