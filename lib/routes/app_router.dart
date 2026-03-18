import 'package:flutter/material.dart';

import '../features/account/presentation/login/screens/login_screen.dart';
import '../features/petition/home_screen.dart';
import '../shared/layouts/page_shell.dart';
import '../shared/widgets/app_bottom_navigator.dart';

class AppRouter {
  static const login = '/login';
  static const home = '/home';
  static const cadastro = '/cadastro';

  static final Set<String> publicRoutes = {login, cadastro, home};

  static const List<AppBottomNavItem> homeBottomItems = [
    AppBottomNavItem(label: 'Home', icon: Icons.home_rounded, route: home),
  ];

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? login;

    final bool isPublic = publicRoutes.contains(routeName);

    if (!isPublic) {
      return MaterialPageRoute(builder: (_) => LoginScreen());
    }

    switch (routeName) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case home:
        return MaterialPageRoute(
          builder: (context) => PageShell(
            appBar: AppBar(title: const Text('Home')),
            body: const HomeScreen(),
            bottomNavigator: AppBottomNavigator(
              currentIndex: 0,
              items: homeBottomItems,
              onTap: (index) {
                final targetRoute = homeBottomItems[index].route;
                if (targetRoute != home) {
                  Navigator.of(context).pushReplacementNamed(targetRoute);
                }
              },
            ),
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
