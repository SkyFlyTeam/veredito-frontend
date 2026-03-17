import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

/// ApiClient provider for dependency injection
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ApiClient.createDio();
  final secureStorage = FlutterSecureStorage();
  return ApiClient(dio, secureStorage);
});
