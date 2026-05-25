import '../../domain/entities/processo_juridico.dart' as domain;

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

  factory ProcessoJuridico.fromJson(Map<String, dynamic> json) {
    return ProcessoJuridico(
      id: json['id'],
      caminhoArquivo: (json['caminho_arquivo'] ?? json['caminhoArquivo']) as String,
      instancia: json['instancia'],
      classeProcessual: (json['classe_processual'] ?? json['classeProcessual']) as String,
      areaDireito: (json['area_direito'] ?? json['areaDireito']) as String,
      pedidos: json['pedidos'],
      fundamentos: json['fundamentos'],
      fatos: json['fatos'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      peticaoId: json['peticaoId'],
      tribunalPrecedenteId: json['tribunalPrecedenteId'] ?? json['tribunal_precedente_id'],
    );
  }

  domain.ProcessoJuridico toEntity() {
    return domain.ProcessoJuridico(
      id: id,
      caminhoArquivo: caminhoArquivo,
      instancia: instancia,
      classeProcessual: classeProcessual,
      areaDireito: areaDireito,
      pedidos: pedidos,
      fundamentos: fundamentos,
      fatos: fatos,
      createdAt: createdAt,
      peticaoId: peticaoId,
      tribunalPrecedenteId: tribunalPrecedenteId,
    );
  }
}