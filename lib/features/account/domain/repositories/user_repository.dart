import '../entities/user.dart';

abstract class UserRepository {
  Future<User> getUser(int id);
  Future<User> updateUser(int id, Map<String, dynamic> data);
  Future<void> createUser(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getAccessLevels();
}
