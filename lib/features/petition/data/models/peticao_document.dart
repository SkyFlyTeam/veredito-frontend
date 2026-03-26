enum PeticaoStatus {
  aguardando,
  emAnalise,
  aprovado,
  reprovado;

  String get label => switch (this) {
    PeticaoStatus.aguardando => 'Aguardando',
    PeticaoStatus.emAnalise => 'Em análise',
    PeticaoStatus.aprovado => 'Aprovado',
    PeticaoStatus.reprovado => 'Reprovado',
  };
}

class PeticaoDocument {
  final String id;
  final String fileName;
  final String extension;
  final DateTime uploadedAt;
  final PeticaoStatus status;

  const PeticaoDocument({
    required this.id,
    required this.fileName,
    required this.extension,
    required this.uploadedAt,
    required this.status,
  });
}

final mockPeticaoDocuments = [
  PeticaoDocument(
    id: '1',
    fileName: 'peticao-inicial',
    extension: 'pdf',
    uploadedAt: DateTime(2026, 3, 20),
    status: PeticaoStatus.aprovado,
  ),
  PeticaoDocument(
    id: '2',
    fileName: 'recurso-administrativa',
    extension: 'docx',
    uploadedAt: DateTime(2026, 3, 18),
    status: PeticaoStatus.emAnalise,
  ),
  PeticaoDocument(
    id: '3',
    fileName: 'contrarrazoes',
    extension: 'pdf',
    uploadedAt: DateTime(2026, 3, 15),
    status: PeticaoStatus.aguardando,
  ),
  PeticaoDocument(
    id: '4',
    fileName: 'memoriais-finais',
    extension: 'txt',
    uploadedAt: DateTime(2026, 3, 10),
    status: PeticaoStatus.reprovado,
  ),
  PeticaoDocument(
    id: '5',
    fileName: 'peticao-liminar',
    extension: 'docx',
    uploadedAt: DateTime(2026, 3, 5),
    status: PeticaoStatus.aprovado,
  ),
  PeticaoDocument(
    id: '6',
    fileName: 'embargos-declaracao',
    extension: 'pdf',
    uploadedAt: DateTime(2026, 2, 28),
    status: PeticaoStatus.emAnalise,
  ),
];
