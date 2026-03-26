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
      icon: Icons.file_open_rounded,
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

  static int _indexForRoute(String route) {
    final index = homeBottomItems.indexWhere((item) => item.route == route);
    return index >= 0 ? index : 0;
  }

  // Builds a simple route for screens with just the page layout and no bottom navigator
  static Route<dynamic> _buildSimpleRoute({required Widget child}) {
    return MaterialPageRoute(builder: (_) => PageLayout(child: child));
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
      case profile:
      case petitionHistory:
        return MaterialPageRoute(
          builder: (_) => _HomeTabsShell(initialRoute: routeName),
        );
      default:
        return _buildSimpleRoute(child: const LoginScreen());
    }
  }
}

class _HomeTabsShell extends StatefulWidget {
  final String initialRoute;

  const _HomeTabsShell({required this.initialRoute});

  @override
  State<_HomeTabsShell> createState() => _HomeTabsShellState();
}

class _HomeTabsShellState extends State<_HomeTabsShell> {
  late int _currentIndex;

  static const List<Widget> _tabScreens = [
    PetitionUploadScreen(),
    PetitionHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = AppRouter._indexForRoute(widget.initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      bottomNavigator: AppBottomNavigator(
        currentIndex: _currentIndex,
        items: AppRouter.homeBottomItems,
        onTap: (index) {
          if (index == _currentIndex) {
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
      ),
      child: IndexedStack(index: _currentIndex, children: _tabScreens),
    );
  }
}
