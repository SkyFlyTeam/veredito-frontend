import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ApiClient to handle HTTP requests
class ApiClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  ApiClient(this.dio, this.secureStorage);

  // Method to initialize Dio
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? 'http://api.myapp.com',
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 3),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Attach JWT token if available
          dio.options.headers['Authorization'] = 'Bearer ${_getToken()}';
          return handler.next(options);
        },
        onError: (DioError e, handler) {
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

  // Method to get token from secure storage
  static Future<String?> _getToken() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'jwt_token');
  }
}
