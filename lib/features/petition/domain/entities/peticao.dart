class Peticao {
  final int id;
  final String caminhoArquivo;
  final String? resumo;
  final DateTime createdAt;
  final int usuarioId;

  const Peticao({
    required this.id,
    required this.caminhoArquivo,
    this.resumo,
    required this.createdAt,
    required this.usuarioId,
  });
}
