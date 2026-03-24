import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_data_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<User> login(String email, String password) async {
    final model = await dataSource.login(email, password);
    await dataSource.saveAccessToken(model.accessToken);
    return model.toEntity();
  }

  @override
  Future<void> logout() async {
    await dataSource.clearAccessToken();
  }
}
