import '../repositories/legal_case_repository.dart';

class UpdateLegalCaseSectionUseCase {
  final LegalCaseRepository _repository;

  UpdateLegalCaseSectionUseCase(this._repository);

  Future<void> execute({
    required int legalCaseId,
    required int secaoId,
    required String conteudo,
  }) {
    return _repository.updateSecao(
      legalCaseId: legalCaseId,
      secaoId: secaoId,
      conteudo: conteudo,
    );
  }
}
