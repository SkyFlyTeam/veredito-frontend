import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/login_usecase_provider.dart';

class LoginForm extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(loginViewModelProvider);

    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Email"),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Password"),
        ),
        const SizedBox(height: 20),

        if (authState.isLoading)
          const CircularProgressIndicator()
        else
          ElevatedButton(
            onPressed: () {
              ref
                  .read(loginViewModelProvider.notifier)
                  .login(emailController.text, passwordController.text);
            },
            child: const Text("Login"),
          ),

        if (authState.error != null)
          Text(authState.error!, style: const TextStyle(color: Colors.red)),
      ],
    );
  }
}
