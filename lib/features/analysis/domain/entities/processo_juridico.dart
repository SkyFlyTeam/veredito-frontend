class ProcessoJuridico {
  final int? id;
  final String caminhoArquivo;
  final int instancia;
  final String classeProcessual;
  final String areaDireito;
  final String? pedidos;
  final String? fundamentos;
  final String? fatos;
  final DateTime? createdAt;
  final int? peticaoId;
  final int? tribunalPrecedenteId;

  ProcessoJuridico({
    this.id,
    required this.caminhoArquivo,
    required this.instancia,
    required this.classeProcessual,
    required this.areaDireito,
    this.pedidos,
    this.fundamentos,
    this.fatos,
    this.createdAt,
    this.peticaoId,
    this.tribunalPrecedenteId,
  });
}