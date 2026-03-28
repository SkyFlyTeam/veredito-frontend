import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_mapper.dart';

import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AuthRemoteDataSource(this.dio, this.secureStorage);

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiErrorMapper.mapDioException(
        e,
        fallbackMessage: 'Erro ao logar. Por favor, tente novamente',
      );
    }
  }

  Future<void> saveAccessToken(String accessToken) async {
    await secureStorage.write(
      key: ApiClient.accessTokenKey,
      value: accessToken,
    );
  }

  Future<void> clearAccessToken() async {
    await secureStorage.delete(key: ApiClient.accessTokenKey);
  }
}
