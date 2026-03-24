import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/api_client.dart';

import '../models/user_model.dart';

class AuthRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AuthRemoteDataSource(this.dio, this.secureStorage);

  Future<UserModel> login(String email, String password) async {
    final response = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return UserModel.fromJson(response.data);
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
