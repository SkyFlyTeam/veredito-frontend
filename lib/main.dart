import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  runApp(const ProviderScope(child: MyApp()));
}
