import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUserUseCase {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  Future<User> execute(int id) async {
    return await repository.getUser(id);
  }
}
