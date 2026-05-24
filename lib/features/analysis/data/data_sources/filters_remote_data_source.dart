
import 'package:dio/dio.dart';

import '../models/especie_precedente.dart';
import '../models/tribunal_precedente.dart';

class FiltersRemoteDataSource {
  final Dio dio;

  FiltersRemoteDataSource({required this.dio});

  Future<List<TribunalPrecedente>> fetchTribunais() async {
    try {
      final response = await dio.get('/tribunal-precedente');
      return (response.data as List).map((e) => TribunalPrecedente.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load tribunais: $e');
    }
  }

  Future<List<EspeciePrecedente>> fetchEspecies() async {
    try {
      final response = await dio.get('/especie-precedente');
      return (response.data as List).map((e) => EspeciePrecedente.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load especies: $e');
    }
  }
}