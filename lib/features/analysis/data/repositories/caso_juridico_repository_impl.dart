import '../../domain/entities/secao_peticao.dart';
import '../../domain/repositories/caso_juridico_repository.dart';
import '../data_sources/caso_juridico_remote_data_source.dart';

class CasoJuridicoRepositoryImpl implements CasoJuridicoRepository {
  final CasoJuridicoRemoteDataSource remoteDataSource;

  CasoJuridicoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SecaoPeticao>> gerarPeticao(int casoId) async {
    try {
      final models = await remoteDataSource.gerarPeticao(casoId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Falha ao gerar petição: $e');
    }
  }
}
