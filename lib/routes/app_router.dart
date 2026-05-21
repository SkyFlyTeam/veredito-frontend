import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/account/presentation/profile/providers/profile_provider.dart';
import '../features/account/presentation/login/providers/session_provider.dart';
import '../features/account/domain/entities/user.dart';
import '../features/history/domain/entities/history.dart';
import '../features/account/presentation/login/screens/login_screen.dart';
import '../features/account/presentation/profile/screens/profile_screen.dart';
import '../features/petition/domain/entities/peticao.dart';
import '../features/precedent/presentation/PrecedentSuggested/screens/analysis_precedent_screen.dart';
import '../features/history/presentation/petition_history/screens/analysis_history_detail_screen.dart';
import '../features/account/presentation/register/screens/register_screen.dart';
import '../shared/layouts/page_layout.dart';
import '../shared/widgets/app_bottom_navigator.dart';
import '../features/petition/presentation/shared/screens/home_screen.dart';
import '../features/history/presentation/petition_history/screens/petition_history_screen.dart';

class AppRouter {
  static const login = '/login';
  static const petitionUpload = '/petition_upload';
  static const profile = '/profile';
  static const petitionHistory = '/petition_history';
  static const register = '/register';
  static const precedentAnalysis = '/precedent_analysis';
  static const peticaoAnalysesHistory = '/peticao_analysis_history';
  static const processAnalysis = '/process_analysis';

  static final Set<String> publicRoutes = {
    login,
    petitionUpload,
    profile,
    petitionHistory,
    precedentAnalysis,
    peticaoAnalysesHistory,
  };

  static List<AppBottomNavItem> getHomeBottomItems(User? user) {
    final middleLabel = (user?.isJuiz ?? false) ? 'Processos' : 'Petições';

    return [
      const AppBottomNavItem(
        label: 'Home',
        svgPath: 'assets/icons/tab_home.svg',
        route: petitionUpload,
      ),
      AppBottomNavItem(
        label: middleLabel,
        svgPath: 'assets/icons/tab_middle.svg',
        route: petitionHistory,
      ),
      const AppBottomNavItem(
        label: 'Perfil',
        svgPath: 'assets/icons/tab_profile.svg',
        route: profile,
      ),
    ];
  }

  static int _indexForRoute(String route, List<AppBottomNavItem> items) {
    final index = items.indexWhere((item) => item.route == route);
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
      case peticaoAnalysesHistory:
        final entry = settings.arguments as AnalysisHistory;
        return MaterialPageRoute(
          builder: (_) => _HomeTabsShell(
            initialRoute: petitionHistory,
            childOverride: AnalysisHistoryDetailScreen(entry: entry),
          ),
        );
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


  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider);
    final items = AppRouter.getHomeBottomItems(user);
    _currentIndex = AppRouter._indexForRoute(widget.initialRoute, items);
    _showChildOverride = widget.childOverride != null;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final navItems = AppRouter.getHomeBottomItems(user);

    return PageLayout(
      bottomNavigator: AppBottomNavigator(
        currentIndex: _currentIndex,
        items: navItems,
        onTap: (index) {
          if (index == _currentIndex && !_showChildOverride) {
            return;
          }

          final profileIndex = navItems.indexWhere((item) => item.route == AppRouter.profile);
          if (index == profileIndex || _currentIndex == profileIndex) {
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
          : IndexedStack(
            index: _currentIndex,
            children: _getScreens(user),
          ),    );
  }

  List<Widget> _getScreens(User? user) {
    return [
      const HomeScreen(),
      const PetitionHistoryScreen(),
      const ProfileScreen(),
    ];
  }
}
