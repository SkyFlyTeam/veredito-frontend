import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ufProvider = FutureProvider<List<String>>((ref) async {
  final dio = Dio();
  final response = await dio.get(
    'https://servicodados.ibge.gov.br/api/v1/localidades/estados?orderBy=nome',
  );
  final list = response.data as List<dynamic>;
  return list.map((e) => e['sigla'] as String).toList()..sort();
});