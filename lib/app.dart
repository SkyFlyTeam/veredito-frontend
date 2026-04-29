import 'package:flutter/material.dart';

import 'package:toastification/toastification.dart';
import 'core/navigation/app_route_observer.dart';
import 'core/navigation/navigation_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        // App-level configuration
        title: 'Veredito',
        theme: AppTheme.darkTheme,
        navigatorKey: NavigationService.navigatorKey,
        navigatorObservers: [appRouteObserver],
        initialRoute: initialRoute,
        onGenerateRoute: AppRouter.generateRoute, // Route handling
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
