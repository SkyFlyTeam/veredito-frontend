import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/legal_case_model.dart';

class LegalCaseRemoteDataSource {
  final Dio dio;

  LegalCaseRemoteDataSource(this.dio);

  Future<LegalCaseModel> create({
    required String areaDireito,
    required String pedidosPrincipais,
    required String tesePretendida,
    required String contextoFaticoFundamentos,
    required String uf,
    int? tribunalPrecedenteId,
    required List<Map<String, dynamic>> files,
  }) async {
    // final formData = FormData();

    // formData.fields.addAll([
    //   MapEntry('area_direito', areaDireito),
    //   MapEntry('pedidos_principais', pedidosPrincipais),
    //   MapEntry('tese_pretendida', tesePretendida),
    //   MapEntry('contexto_fatico_fundamentos', contextoFaticoFundamentos),
    //   MapEntry('uf', uf),
    //   if (tribunalPrecedenteId != null)
    //     MapEntry('tribunalPrecedenteId', tribunalPrecedenteId.toString()),
    // ]);

    // for (final file in files) {
    //   final originalName = file['name'] as String;
    //   formData.files.add(
    //     MapEntry(
    //       'files',
    //       MultipartFile.fromBytes(
    //         file['bytes'] as List<int>,
    //         filename: _normalizeFileName(originalName),
    //       ),
    //     ),
    //   );
    // }

    // final response = await dio.post('/caso-juridico', data: formData);

    final casoMockado = LegalCaseModel(
      id: int.tryParse(dotenv.env['MOCKED_CASO_JURIDICO_ID'] ?? '1') ?? 1,
      areaDireito: 'Direito Tributário',
      pedidosPrincipais: 'Sustentação sa integralização do imóvel ao capital social amparada pela imunidade tributária.',
      tesePretendida: 'A Secretária de Fazenda do Município de Guarapari deve ser abstecer de cobrar o ITBI.',
      uf: 'ES',
      tribunalPrecedenteId: 20,
      createdAt: DateTime.now(),
      usuarioId: 3,
      fatosEstruturados: '''Fernando de Abreu é o proprietário de um imóvel que foi incorporado ao patrimônio municipal. Em decorrência dessa incorporação, o Município decidiu aplicar a incidência do Imposto de Transmissão de Bens Imóveis (ITBI) sobre a operação, estabelecendo o valor de R\$ 17.690,00 a ser pago. A notificação referente ao ITBI foi emitida com vencimento em 28/05/2021, conforme documento apresentado. A decisão do Município está fundamentada na interpretação da legislação tributária vigente, que prevê a incidência do imposto em operações de transmissão de bens imóveis, mesmo em casos de incorporação ao patrimônio público.''',
      fundamentosJuridicos:  'O artigo 156, inciso II, da Constituição Federal, estabelece que compete aos Municípios instituir impostos sobre a transmissão ''inter vivos'' de bens imóveis, o que inclui a operação em questão. Além disso, o artigo 36, inciso I, do Código Tributário Nacional (CTN) reforça a possibilidade de incidência do ITBI nas operações de transmissão de propriedade. Contudo, é importante considerar a imunidade prevista na legislação, que pode ser aplicada em determinadas situações, como a transferência de bens para entidades públicas, o que deve ser analisado à luz do caso concreto', 
    );

    await Future.delayed(const Duration(seconds: 1)); // Simula um atraso na resposta da API

    return casoMockado;
  }

  Future<void> updateSecao({
    required int legalCaseId,
    required int secaoId,
    required String conteudo,
  }) async {
    await dio.patch(
      '/caso-juridico/$legalCaseId/$secaoId',
      data: {'conteudo': conteudo},
    );
  }

  Future<Uint8List> downloadPeticao({
    required int legalCaseId,
  }) async {
    final response = await dio.get<List<int>>(
      '/caso-juridico/$legalCaseId/download-peticao',
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (_) => true,
      ),
    );

    final statusCode = response.statusCode ?? 0;
    final body = response.data;
    if (statusCode != 200 || body == null || body.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'Download peticao falhou (status: $statusCode).',
        type: DioExceptionType.badResponse,
      );
    }

    return Uint8List.fromList(body);
  }

  String _normalizeFileName(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return fileName;
    }

    final baseName = fileName.substring(0, dotIndex);
    final extension = fileName.substring(dotIndex + 1).toLowerCase();
    return '$baseName.$extension';
  }
}
