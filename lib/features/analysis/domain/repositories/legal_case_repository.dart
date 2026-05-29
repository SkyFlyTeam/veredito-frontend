import '../entities/legal_case.dart';

abstract class LegalCaseRepository {
  Future<LegalCase> create({
    required String areaDireito,
    required String pedidosPrincipais,
    required String tesePretendida,
    required String fatosEstruturados,
    required String fundamentosJuridicos,
    required String uf,
    int? tribunalPrecedenteId,
    required List<Map<String, dynamic>> files,
  });
}
