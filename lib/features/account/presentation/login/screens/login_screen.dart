import 'package:flutter/material.dart';
import '../../../../../shared/widgets/app_background.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Permite que o AppBackground por trás apareça
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LoginForm(),
        ),
      ),
    );
  }
}
