import '../models/secao_peticao.dart';

class CasoJuridicoRemoteDataSource {
  // TODO: remover mock e restaurar Dio quando o backend estiver disponível
  // final Dio dio;
  // CasoJuridicoRemoteDataSource({required this.dio});

  CasoJuridicoRemoteDataSource({dio});

  Future<List<SecaoPeticao>> gerarPeticao(int casoId) async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      SecaoPeticao(
        id: 1,
        titulo: 'Endereçamento',
        conteudo:
            'EXCELENTÍSSIMO SENHOR DESEMBARGADOR PRESIDENTE DO EGRÉGIO TRIBUNAL DE JUSTIÇA DO ESTADO DO ESPÍRITO SANTO\n\nAÇÃO POPULAR COM PEDIDO DE TUTELA DE URGÊNCIA',
      ),
      SecaoPeticao(
        id: 2,
        titulo: 'Dos Fatos',
        conteudo:
            'O autor, cidadão domiciliado no Município de Santa Catarina, vem à presença deste Egrégio Tribunal propor ação popular em defesa do patrimônio público, tendo em vista ato administrativo eivado de ilegalidade e lesividade ao erário municipal, consoante documentos acostados aos autos.',
      ),
      SecaoPeticao(
        id: 3,
        titulo: 'Dos Pedidos',
        conteudo:
            'Nos termos do art. 5º, LXXIII, da Constituição Federal, qualquer cidadão é parte legítima para propor ação popular que vise anular ato lesivo ao patrimônio público. A Lei nº 4.717/65 regulamenta o procedimento, sendo cabível a concessão de liminar para suspensão do ato impugnado.',
      ),
    ];
  }
}
