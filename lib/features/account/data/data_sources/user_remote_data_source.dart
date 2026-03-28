import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  UserRemoteDataSource(this.dio, this.secureStorage);

  Future<UserModel> getUser(int id) async {
    final response = await dio.get('/users/$id');
    final accessToken = await secureStorage.read(key: ApiClient.accessTokenKey) ?? '';
    return UserModel.fromProfileJson(response.data, accessToken);
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    final response = await dio.patch('/users/$id', data: data);
    final accessToken = await secureStorage.read(key: ApiClient.accessTokenKey) ?? '';
    return UserModel.fromProfileJson(response.data, accessToken);
  }
}
