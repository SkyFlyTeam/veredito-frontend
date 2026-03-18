import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App-level configuration
      title: 'Veredito',
      theme: AppTheme.darkTheme,
      initialRoute: '/login', // Initial screen
      onGenerateRoute: AppRouter.generateRoute, // Route handling
      debugShowCheckedModeBanner: false,
    );
  }
}
