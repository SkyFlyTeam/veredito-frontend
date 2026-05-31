import 'dart:typed_data';

import '../repositories/legal_case_repository.dart';

class DownloadLegalCasePeticaoUseCase {
  final LegalCaseRepository _repository;

  DownloadLegalCasePeticaoUseCase(this._repository);

  Future<Uint8List> execute({
    required int legalCaseId,
  }) {
    return _repository.downloadPeticao(legalCaseId: legalCaseId);
  }
}
