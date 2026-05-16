import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_select.dart';
import '../../../../../shared/widgets/message_box.dart';
import '../../shared/email_input.dart';
import '../../shared/name_input.dart';
import '../../shared/password_input.dart';
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
  String? _selectedAccessLevelName;

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
      setState(() {
        _formWithError = "Por favor, preencha todos os campos corretamente.";
      });
      return;
    }

    if (_selectedAccessLevelName == null) {
      setState(() {
        _formWithError = "Por favor, selecione um cargo.";
      });
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
        .register(name, email, password, _selectedAccessLevelName!);
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerViewModelProvider);
    final accessLevelsAsync = ref.watch(accessLevelsProvider);

    final displayError = _formWithError ?? registerState.error;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
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
          const SizedBox(height: 5),

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
            showError:
                _formWithError != null ||
                (registerState.error?.contains('Email') ?? false),
            isLoading: registerState.isLoading,
          ),
          
          accessLevelsAsync.when(
            data: (levels) => AppSelect<String>(
              label: 'Cargo',
              hintText: 'Selecione seu cargo',
              initialSelection: _selectedAccessLevelName,
              icon: Icons.work_outline,
              entries: levels.map((level) {
                final nome = level['nome'].toString();
                String formattedNome = nome[0].toUpperCase() + nome.substring(1).toLowerCase();
                
                if (nome.toLowerCase() == 'user') {
                  formattedNome = 'Usuário';
                }

                return DropdownMenuEntry<String>(
                  value: nome,
                  label: formattedNome,
                );
              }).toList(),
              onSelected: (name) => setState(() => _selectedAccessLevelName = name),
              enabled: !registerState.isLoading,
              expandedInsets: EdgeInsets.zero,
            ),
            loading: () => AppSelect<String>(
              label: 'Cargo',
              hintText: 'Carregando cargos...',
              entries: const [],
              enabled: false,
              expandedInsets: EdgeInsets.zero,
            ),
            error: (err, stack) => AppSelect<String>(
              label: 'Cargo',
              hintText: 'Erro ao carregar cargos',
              entries: const [],
              enabled: false,
              expandedInsets: EdgeInsets.zero,
            ),
          ),

          PasswordInput(
            controller: passwordController,
            onChanged: _onFieldChanged,
            showError: _formWithError != null,
            isLoading: registerState.isLoading,
          ),

          const SizedBox(height: 5),
          AppButton(
            label: registerState.isLoading ? 'Cadastrando...' : 'Cadastrar',
            onPressed: _onSubmit,
            isLoading: registerState.isLoading,
            mainAxisSize: MainAxisSize.min,
          ),
        ],
      ),
     ),
    );
  }
}
