import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/account/presentation/login/screens/login_screen.dart';
import '../features/account/presentation/profile/screens/profile_screen.dart';

import '../features/petition/presentation/petition_history/screens/petition_history_screen.dart';
import '../features/petition/presentation/petition_upload/screens/petition_upload_screen.dart';
import '../shared/layouts/page_layout.dart';
import '../shared/providers/home_tab_provider.dart';
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
          builder: (_) => const _HomeTabsShell(),
        );
      default:
        return _buildSimpleRoute(child: const LoginScreen());
    }
  }
}

class _HomeTabsShell extends ConsumerWidget {
  const _HomeTabsShell();

  static const List<Widget> _tabScreens = [
    PetitionUploadScreen(),
    PetitionHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabProvider);

    return PageLayout(
      bottomNavigator: AppBottomNavigator(
        currentIndex: currentIndex,
        items: AppRouter.homeBottomItems,
        onTap: (index) {
          if (index == currentIndex) return;
          ref.read(homeTabProvider.notifier).state = index;
        },
      ),
      child: IndexedStack(index: currentIndex, children: _tabScreens),
    );
  }
}
