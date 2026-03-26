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

//     // 👇 usando context global
//     NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
//       AppRouter.login,
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(sessionProvider);

//     if (user == null) {
//       return const Center(child: Text('Nenhum usuário logado'));
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             'Perfil do Usuário',
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),

//           Text('ID: ${user.id}'),
//           Text('Nome: ${user.nome}'),
//           Text('Sobrenome: ${user.sobrenome}'),
//           Text('Email: ${user.email}'),
//           Text('Role: ${user.role}'),

//           const SizedBox(height: 30),

//           TextButton(
//             onPressed: () => _logout(ref),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
// }