import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/account/presentation/profile/providers/profile_provider.dart';

import '../features/account/presentation/login/screens/login_screen.dart';
import '../features/account/presentation/profile/screens/profile_screen.dart';
import '../features/petition/domain/entities/peticao.dart';
import '../features/precedent/presentation/PrecedentSuggested/screens/analysis_precedent_screen.dart';

import '../features/account/presentation/register/screens/register_screen.dart';
import '../features/history/presentation/petition_history/screens/petition_history_screen.dart';
import '../features/petition/presentation/petition_upload/screens/petition_upload_screen.dart';
import '../shared/layouts/page_layout.dart';
import '../shared/widgets/app_bottom_navigator.dart';

class AppRouter {
  static const login = '/login';
  static const petitionUpload = '/petition_upload';
  static const profile = '/profile';
  static const petitionHistory = '/petition_history';
  static const register = '/register';
  static const precedentAnalysis = '/precedent_analysis';

  static final Set<String> publicRoutes = {
    login,
    petitionUpload,
    profile,
    petitionHistory,
    precedentAnalysis,
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

    switch (routeName) {
      case login:
        return _buildSimpleRoute(child: const LoginScreen());
      case register:
        return _buildSimpleRoute(child: const RegisterScreen());
      case precedentAnalysis:
        final petitionArg = settings.arguments;
        final petition = petitionArg is Peticao ? petitionArg : null;
        return MaterialPageRoute(
          builder: (_) => _HomeTabsShell(
            initialRoute: petitionUpload,
            childOverride: AnalysisPrecedentScreen(petition: petition),
          ),
        );
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
  final Widget? childOverride;

  const _HomeTabsShell({required this.initialRoute, this.childOverride});

  @override
  ConsumerState<_HomeTabsShell> createState() => _HomeTabsShellState();
}

class _HomeTabsShellState extends ConsumerState<_HomeTabsShell> {
  late int _currentIndex;
  late bool _showChildOverride;

  static const List<Widget> _tabScreens = [
    PetitionUploadScreen(),
    PetitionHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = AppRouter._indexForRoute(widget.initialRoute);
    _showChildOverride = widget.childOverride != null;
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      bottomNavigator: AppBottomNavigator(
        currentIndex: _currentIndex,
        items: AppRouter.homeBottomItems,
        onTap: (index) {
          if (index == _currentIndex && !_showChildOverride) {
            return;
          }

          // Reset profile state when switching away from OR to the Profile tab
          if (index == 3 || _currentIndex == 3) {
            ref.read(profileViewModelProvider.notifier).resetState();
          }

          setState(() {
            _currentIndex = index;
            _showChildOverride = false;
          });
        },
      ),
      child: _showChildOverride && widget.childOverride != null
          ? widget.childOverride!
          : IndexedStack(index: _currentIndex, children: _tabScreens),
    );
  }
}
