import 'package:flutter_cookiecutter/features/account/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> execute() async {
    return await repository.logout();
  }
}
