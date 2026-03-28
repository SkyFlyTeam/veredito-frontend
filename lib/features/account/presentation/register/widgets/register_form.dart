import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/message_box.dart';
import '../../shared_widgets/email_input.dart';
import '../../shared_widgets/name_input.dart';
import '../../shared_widgets/password_input.dart';
import '../providers/register_usecase_provider.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? _formWithError;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onFieldChanged(String _) {
    if (_formWithError != null) {
      setState(() {
        _formWithError = null;
      });
    }
  }

  void _onSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();

    setState(() {
      _formWithError = null;
    });

    ref
        .read(registerViewModelProvider.notifier)
        .register(name, email, password);
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerViewModelProvider);

    final displayError = _formWithError ?? registerState.error;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 25,
        children: [
          Text(
            'CRIE SUA CONTA',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),

          if (displayError != null)
            MessageBox(message: displayError, variant: MessageBoxVariant.error),

          NameInput(
            controller: nameController,
            onChanged: _onFieldChanged,
            showError: _formWithError != null,
            isLoading: registerState.isLoading,
          ),
          EmailInput(
            controller: emailController,
            onChanged: _onFieldChanged,
            showError: _formWithError != null,
            isLoading: registerState.isLoading,
          ),
          PasswordInput(
            controller: passwordController,
            onChanged: _onFieldChanged,
            showError: _formWithError != null,
            isLoading: registerState.isLoading,
          ),

          const SizedBox(height: 20),
          AppButton(
            label: registerState.isLoading ? 'Cadastrando...' : 'Cadastrar',
            onPressed: _onSubmit,
            isLoading: registerState.isLoading,
            mainAxisSize: MainAxisSize.min,
          ),
        ],
      ),
    );
  }
}
