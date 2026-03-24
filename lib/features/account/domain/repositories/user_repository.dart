import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> getUser(int id);
  Future<User> updateUser(int id, Map<String, dynamic> data);
}
