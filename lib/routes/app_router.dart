import 'package:flutter/material.dart';

import '../features/account/presentation/login/screens/login_screen.dart';

class AppRouter {
  static const login = '/login';

  static final Set<String> publicRoutes = {login, '/cadatro', '/home'};

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? login;

    final bool isPublic = publicRoutes.contains(routeName);

    if (!isPublic) {
      return MaterialPageRoute(builder: (_) => LoginScreen());
    }

    switch (routeName) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
