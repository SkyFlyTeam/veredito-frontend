import '../entities/user.dart';
import '../repositories/user_repository.dart';

class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  Future<User> execute(int id, Map<String, dynamic> data) async {
    return await repository.updateUser(id, data);
  }
}
