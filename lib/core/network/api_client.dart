import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../navigation/navigation_service.dart';
import '../../routes/app_router.dart';

class ApiClient {
  static const String accessTokenKey = 'access_token';

  final Dio dio;
  final FlutterSecureStorage secureStorage;

  ApiClient(this.dio, this.secureStorage);

  static Dio createDio(FlutterSecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: accessTokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Limpa o token salvo
            await secureStorage.delete(key: accessTokenKey);
            // Redireciona para o login limpando toda a pilha de navegação
            NavigationService.navigatorKey.currentState
                ?.pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }
}
