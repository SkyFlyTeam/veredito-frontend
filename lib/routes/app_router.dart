import 'package:flutter/material.dart';

import '../features/account/presentation/login/screens/login_screen.dart';
import '../features/account/presentation/profile/screens/profile_screen.dart';

import '../features/petition/presentation/petition_history/screens/petition_history_screen.dart';
import '../features/petition/presentation/petition_upload/screens/petition_upload_screen.dart';
import '../shared/layouts/page_layout.dart';
import '../shared/widgets/app_bottom_navigator.dart';

class AppRouter {
  static const login = '/login';
  static const petitionUpload = '/petition_upload';
  static const profile = '/profile';
  static const petitionHistory = '/petition_history';

  static final Set<String> publicRoutes = {
    login,
    petitionUpload,
    profile,
    petitionHistory,
  };

  static const List<AppBottomNavItem> homeBottomItems = [
    AppBottomNavItem(
      label: 'Petition',
      icon: Icons.home_rounded,
      route: petitionUpload,
    ),
    AppBottomNavItem(
      label: 'History',
      icon: Icons.history_rounded,
      route: petitionHistory,
    ),
    AppBottomNavItem(
      label: 'Profile',
      icon: Icons.person_rounded,
      route: profile,
    ),
  ];

  // Builds a simple route for screens with just the page layout and no bottom navigator
  static Route<dynamic> _buildSimpleRoute({required Widget child}) {
    return MaterialPageRoute(builder: (_) => PageLayout(child: child));
  }

  // Builds a route for the main app screens that include the bottom navigator
  static Route<dynamic> _buildPageWithNavigatorRoute({
    required String currentRoute,
    required Widget child,
  }) {
    final currentIndex = homeBottomItems.indexWhere(
      (item) => item.route == currentRoute,
    );

    return MaterialPageRoute(
      builder: (context) => PageLayout(
        bottomNavigator: AppBottomNavigator(
          currentIndex: currentIndex >= 0 ? currentIndex : 0,
          items: homeBottomItems,
          onTap: (index) {
            final targetRoute = homeBottomItems[index].route;
            if (targetRoute != currentRoute) {
              Navigator.of(context).pushReplacementNamed(targetRoute);
            }
          },
        ),
        child: child,
      ),
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? login;

    final bool isPublic = publicRoutes.contains(routeName);

    if (!isPublic) {
      return _buildSimpleRoute(child: const LoginScreen());
    }

    switch (routeName) {
      case login:
        return _buildSimpleRoute(child: const LoginScreen());
      case petitionUpload:
        return _buildPageWithNavigatorRoute(
          currentRoute: petitionUpload,
          child: const PetitionUploadScreen(),
        );
      case profile:
        return _buildPageWithNavigatorRoute(
          currentRoute: profile,
          child: const ProfileScreen(),
        );
      case petitionHistory:
        return _buildPageWithNavigatorRoute(
          currentRoute: petitionHistory,
          child: const PetitionHistoryScreen(),
        );
      default:
        return _buildSimpleRoute(child: const LoginScreen());
    }
  }
}
