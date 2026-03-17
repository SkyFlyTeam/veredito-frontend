import 'package:flutter/material.dart';

import 'routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App-level configuration
      title: 'MyApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login', // Initial screen
      onGenerateRoute: AppRouter.generateRoute, // Route handling
    );
  }
}
