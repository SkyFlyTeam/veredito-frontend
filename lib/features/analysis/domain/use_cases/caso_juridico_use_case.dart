import '../entities/secao_peticao.dart';
import '../repositories/caso_juridico_repository.dart';

class CasoJuridicoUseCase {
  final CasoJuridicoRepository repository;

  CasoJuridicoUseCase({required this.repository});

  Future<List<SecaoPeticao>> gerarPeticao(int casoId) {
    return repository.gerarPeticao(casoId);
  }
}
