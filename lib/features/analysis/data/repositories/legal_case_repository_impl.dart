import 'dart:typed_data';

import '../../domain/entities/legal_case.dart';
import '../../domain/repositories/legal_case_repository.dart';
import '../data_sources/legal_case_remote_data_source.dart';

class LegalCaseRepositoryImpl implements LegalCaseRepository {
  final LegalCaseRemoteDataSource dataSource;

  LegalCaseRepositoryImpl(this.dataSource);

  @override
  Future<LegalCase> create({
    required String areaDireito,
    required String pedidosPrincipais,
    required String tesePretendida,
    required String contextoFaticoFundamentos,
    required String uf,
    int? tribunalPrecedenteId,
    required List<Map<String, dynamic>> files,
  }) async {
    final model = await dataSource.create(
      areaDireito: areaDireito,
      pedidosPrincipais: pedidosPrincipais,
      tesePretendida: tesePretendida,
      contextoFaticoFundamentos: contextoFaticoFundamentos,
      uf: uf,
      tribunalPrecedenteId: tribunalPrecedenteId,
      files: files,
    );
    return model.toEntity();
  }

  @override
  Future<void> updateSecao({
    required int legalCaseId,
    required int secaoId,
    required String conteudo,
  }) {
    return dataSource.updateSecao(
      legalCaseId: legalCaseId,
      secaoId: secaoId,
      conteudo: conteudo,
    );
  }

  @override
  Future<Uint8List> downloadPeticao({
    required int legalCaseId,
  }) {
    return dataSource.downloadPeticao(legalCaseId: legalCaseId);
  }
}
