import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Welcome to the Profile Screen!'));
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../../../../../core/navigation/navigation_service.dart';
// import '../../../../../core/network/api_client.dart';
// import '../../../../../routes/app_router.dart';
// import '../../../../account/presentation/login/providers/session_provider.dart';

// class ProfileScreen extends ConsumerWidget {
//   const ProfileScreen({super.key});

//   Future<void> _logout(WidgetRef ref) async {
//     const secureStorage = FlutterSecureStorage();
//     await secureStorage.delete(key: ApiClient.accessTokenKey);
//     ref.read(sessionProvider.notifier).clearUser();
//     NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
//       AppRouter.login,
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Center(
//       child: TextButton(
//         onPressed: () => _logout(ref),
//         child: const Text('Logout'),
//       ),
//     );
//   }
// }