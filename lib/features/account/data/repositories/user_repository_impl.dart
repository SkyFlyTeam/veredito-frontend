import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';
import 'package:flutter_cookiecutter/features/account/domain/repositories/user_repository.dart';
import 'package:flutter_cookiecutter/features/account/data/data_sources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> getUser(int id) async {
    final userModel = await remoteDataSource.getUser(id);
    return userModel.toEntity();
  }

  @override
  Future<User> updateUser(int id, Map<String, dynamic> data) async {
    final userModel = await remoteDataSource.updateUser(id, data);
    return userModel.toEntity();
  }
}
