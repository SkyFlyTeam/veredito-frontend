import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ApiClient to handle HTTP requests
class ApiClient {
  static const String accessTokenKey = 'access_token';

  final Dio dio;
  final FlutterSecureStorage secureStorage;

  ApiClient(this.dio, this.secureStorage);

  // Method to initialize Dio
  static Dio createDio(FlutterSecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach JWT token if available
          final token = await secureStorage.read(key: accessTokenKey);

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle errors globally
          if (e.response?.statusCode == 401) {
            // Handle unauthorized (e.g., navigate to login)
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }
}
