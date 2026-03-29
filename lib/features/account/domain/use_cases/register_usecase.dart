import '../repositories/user_repository.dart';

class RegisterUsecase {
  final UserRepository userRepository;

  RegisterUsecase(this.userRepository);

  Future<void> execute(String name, String email, String password) async {
    final firstName = name.split(' ').first;
    final lastName = name.split(' ').length > 1
        ? name.split(' ').sublist(1).join(' ')
        : '';

    final data = {
      'nome': firstName,
      'sobrenome': lastName,
      'email': email,
      'password': password,
      'accessLevel': 'superuser',
    };
    await userRepository.createUser(data);
  }
}
