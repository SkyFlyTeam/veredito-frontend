import 'package:dio/dio.dart';
import '../models/secao_peticao.dart';

class CasoJuridicoRemoteDataSource {
  final Dio dio;

  CasoJuridicoRemoteDataSource({required this.dio});

  Future<List<SecaoPeticao>> gerarPeticao(int casoId) async {
    try {
      final response = await dio.post<List<dynamic>>(
        '/caso-juridico/$casoId/gerar-peticao',
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Resposta inválida do servidor');
      }

      return data
          .map((item) => SecaoPeticao.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Falha ao gerar petição: ${e.message}');
    } catch (e) {
      throw Exception('Falha ao gerar petição: $e');
    }
  }
}
