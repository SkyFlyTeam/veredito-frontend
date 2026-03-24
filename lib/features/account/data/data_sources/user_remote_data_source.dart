import 'package:dio/dio.dart';
import 'package:flutter_cookiecutter/features/account/data/models/user_model.dart';

class UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSource(this.dio);

  Future<UserModel> getUser(int id) async {
    final response = await dio.get('/users/$id');
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    final response = await dio.patch('/users/$id', data: data);
    return UserModel.fromJson(response.data);
  }
}
