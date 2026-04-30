import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../navigation/navigation_service.dart';
import '../../routes/app_router.dart';

class ApiClient {
  static const String accessTokenKey = 'access_token';
  final Dio dio;
  final Dio sseDio;
  final FlutterSecureStorage secureStorage;

  ApiClient(this.dio, this.sseDio, this.secureStorage);

  static ApiClient create(FlutterSecureStorage secureStorage) {
    final dio = createDio(secureStorage);
    final sseDio = createSseDio(secureStorage);
    return ApiClient(dio, sseDio, secureStorage);
  }

  static Dio createDio(FlutterSecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 90),
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
            await secureStorage.delete(key: accessTokenKey);
            NavigationService.navigatorKey.currentState
                ?.pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  static Dio createSseDio(FlutterSecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: Duration.zero, // sem timeout para stream contínuo
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
            await secureStorage.delete(key: accessTokenKey);
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
