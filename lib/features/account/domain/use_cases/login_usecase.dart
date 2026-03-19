import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<User> execute(String email, String password) {
    // return repository.login(email, password);
    return Future.value(
      User(
        id: '1',
        email: email,
        name: 'Test User',
        token: 'dummy_token',
        acessLevel: 'user',
      ),
    );
  }
}
