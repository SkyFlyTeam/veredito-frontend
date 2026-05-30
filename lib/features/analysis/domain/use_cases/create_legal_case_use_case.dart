import '../entities/legal_case.dart';
import '../repositories/legal_case_repository.dart';

class CreateLegalCaseUsecase {
  final LegalCaseRepository _repository;

  CreateLegalCaseUsecase(this._repository);

  Future<LegalCase> execute({
    required String areaDireito,
    required String pedidosPrincipais,
    required String tesePretendida,
    required String contextoFaticoFundamentos,
    required String uf,
    int? tribunalPrecedenteId,
    required List<Map<String, dynamic>> files,
  }) {
    return _repository.create(
      areaDireito: areaDireito,
      pedidosPrincipais: pedidosPrincipais,
      tesePretendida: tesePretendida,
      contextoFaticoFundamentos: contextoFaticoFundamentos,
      uf: uf,
      tribunalPrecedenteId: tribunalPrecedenteId,
      files: files,
    );
  }
}
