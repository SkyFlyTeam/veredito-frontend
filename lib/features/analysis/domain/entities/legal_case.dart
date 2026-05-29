class LegalCase {
  final int id;
  final String areaDireito;
  final String pedidosPrincipais;
  final String tesePretendida;
  final String uf;
  final String? fatosEstruturados;
  final String? fundamentosJuridicos;
  final int? tribunalPrecedenteId;
  final DateTime createdAt;
  final int usuarioId;

  LegalCase({
    required this.id,
    required this.areaDireito,
    required this.pedidosPrincipais,
    required this.tesePretendida,
    required this.uf,
    this.fatosEstruturados,
    this.fundamentosJuridicos,
    this.tribunalPrecedenteId,
    required this.createdAt,
    required this.usuarioId,
  });
}