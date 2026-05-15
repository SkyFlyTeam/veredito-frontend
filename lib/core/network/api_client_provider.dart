import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_cookiecutter/core/network/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  const secureStorage = FlutterSecureStorage();
  return ApiClient.create(secureStorage);
});
