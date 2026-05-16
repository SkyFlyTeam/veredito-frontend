import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'features/account/presentation/login/providers/session_provider.dart';
import 'features/history/presentation/petition_history/providers/history_provider.dart';
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
  await dotenv.load(fileName: envFile);

  // Initialize SharedPreferences for history feature
  final prefs = await SharedPreferences.getInstance();

  const secureStorage = FlutterSecureStorage();
  final token = await secureStorage.read(key: ApiClient.accessTokenKey);
  final hasSession = token != null && token.isNotEmpty;
  final initialRoute = hasSession ? AppRouter.petitionUpload : AppRouter.login;

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  if (hasSession) {
    await container.read(sessionProvider.notifier).restoreSession();
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}
