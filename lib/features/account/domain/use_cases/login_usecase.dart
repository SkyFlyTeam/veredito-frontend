import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<User> execute(String email, String password) {
    return repository.login(email, password);
  }
}
