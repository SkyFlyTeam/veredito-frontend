import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/network/api_client.dart';
import 'routes/app_router.dart';
import 'app.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String envFile = 'lib/core/environment/.env.dev';

  if (appFlavor == 'prod') {
    envFile = 'lib/core/environment/.env.prod';
  } else if (appFlavor == 'stg') {
    envFile = 'lib/core/environment/.env.stg';
  }

  // Load the file
  await dotenv.load(fileName: envFile);

  const secureStorage = FlutterSecureStorage();
  final token = await secureStorage.read(key: ApiClient.accessTokenKey);
  final initialRoute = (token != null && token.isNotEmpty)
      ? AppRouter.petitionUpload
      : AppRouter.login;

  runApp(ProviderScope(child: MyApp(initialRoute: initialRoute)));
}
