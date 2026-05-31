import '../entities/secao_peticao.dart';

abstract class CasoJuridicoRepository {
  Future<List<SecaoPeticao>> gerarPeticao(int casoId);
}
