import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  final Dio dio;
  final Dio publicDio;
  final FlutterSecureStorage secureStorage;

  UserRemoteDataSource(this.dio, this.publicDio, this.secureStorage);

  Future<UserModel> getUser(int id) async {
    final response = await dio.get('/users/$id');
    final accessToken =
        await secureStorage.read(key: ApiClient.accessTokenKey) ?? '';
    return UserModel.fromProfileJson(response.data, accessToken);
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    final response = await dio.patch('/users/$id', data: data);
    final accessToken =
        await secureStorage.read(key: ApiClient.accessTokenKey) ?? '';
    return UserModel.fromProfileJson(response.data, accessToken);
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    try {
      await publicDio.post('/users', data: data);
    } on DioException catch (e) {
      throw ApiErrorMapper.mapDioException(
        e,
        fallbackMessage:
            'Ocorreu um erro ao registrar. Por favor, tente novamente.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAccessLevels() async {
    try {
      final response = await publicDio.get('/access-level');
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } on DioException catch (e) {
      throw ApiErrorMapper.mapDioException(
        e,
        fallbackMessage: 'Ocorreu um erro ao buscar os níveis de acesso.',
      );
    }
  }
}
