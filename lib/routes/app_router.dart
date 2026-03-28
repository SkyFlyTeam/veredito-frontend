import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/account/presentation/profile/providers/profile_provider.dart';

import '../features/account/presentation/login/screens/login_screen.dart';
import '../features/account/presentation/profile/screens/profile_screen.dart';

import '../features/account/presentation/register/screens/register_screen.dart';
import '../features/petition/presentation/petition_history/screens/petition_history_screen.dart';
import '../features/petition/presentation/petition_upload/screens/petition_upload_screen.dart';
import '../shared/layouts/page_layout.dart';
import '../shared/widgets/app_bottom_navigator.dart';

class AppRouter {
  static const login = '/login';
  static const petitionUpload = '/petition_upload';
  static const profile = '/profile';
  static const petitionHistory = '/petition_history';
  static const register = '/register';

  static final Set<String> publicRoutes = {login, register};

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

    switch (routeName) {
      case login:
        return _buildSimpleRoute(child: const LoginScreen());
      case register:
        return _buildSimpleRoute(child: const RegisterScreen());
      case petitionUpload:
      case profile:
      case petitionHistory:
        return MaterialPageRoute(
          builder: (_) => _HomeTabsShell(initialRoute: routeName),
        );
      default:
        // Unknown route fallback.
        return _buildSimpleRoute(child: const LoginScreen());
    }
  }
}

class _HomeTabsShell extends ConsumerStatefulWidget {
  final String initialRoute;

  const _HomeTabsShell({required this.initialRoute});

  @override
  ConsumerState<_HomeTabsShell> createState() => _HomeTabsShellState();
}

class _HomeTabsShellState extends ConsumerState<_HomeTabsShell> {
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

          // Reset profile state when switching away from OR to the Profile tab
          if (index == 2 || _currentIndex == 2) {
            ref.read(profileViewModelProvider.notifier).resetState();
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
