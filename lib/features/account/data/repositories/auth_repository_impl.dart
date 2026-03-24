import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_data_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl(this.dataSource, this.secureStorage);

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
