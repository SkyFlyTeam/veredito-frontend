import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../routes/app_router.dart';
import '../../../../../shared/layouts/page_layout.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_logo.dart';
import '../../../../../shared/widgets/message_box.dart';
import '../providers/login_usecase_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
  );

  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  bool _obscurePassword = true;
  String? _requiredFieldsError;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty && password.isEmpty) {
      setState(() {
        _requiredFieldsError = 'Email e Senha não preenchidos.';
      });
      return;
    }

    if (email.isEmpty) {
      setState(() {
        _requiredFieldsError = 'Email não preenchido.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _requiredFieldsError = 'Senha não preenchida.';
      });
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      setState(() {
        _requiredFieldsError = 'Email inválido. Informe um email válido com @.';
      });
      return;
    }

    if (!_passwordRegex.hasMatch(password)) {
      setState(() {
        _requiredFieldsError =
            'Senha inválida. Use ao menos 8 caracteres, com letra maiúscula, número e caractere especial.';
      });
      return;
    }

    setState(() {
      _requiredFieldsError = null;
    });

    ref
        .read(loginViewModelProvider.notifier)
        .login(emailController.text.trim(), passwordController.text);
  }

  void _onRegisterTap() {
    // Colocar o link para o cadastro quando tiver a tela de cadastro pronta
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(loginViewModelProvider, (previous, next) {
      final finishedLoading = (previous?.isLoading ?? false) && !next.isLoading;
      final loginSucceeded = next.error == null;

      if (finishedLoading && loginSucceeded) {
        Navigator.of(context).pushReplacementNamed(AppRouter.petitionUpload);
      }
    });

    final authState = ref.watch(loginViewModelProvider);
    final textTheme = Theme.of(context).textTheme;
    final displayError = _requiredFieldsError ?? authState.error;
    final hasValidationError = displayError != null;
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.red300),
    );

    return PageLayout(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(isHorizontal: false),
                  const SizedBox(height: 55),
                  Text(
                    'Analise peticoes iniciais e receba sugestoes de precedentes judiciais',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 55),
                  Text(
                    'LOGIN',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 45),
                  if (displayError != null)
                    MessageBox(
                      message: displayError,
                      variant: MessageBoxVariant.error,
                    ),
                  if (displayError != null) const SizedBox(height: 25),
                  Text('Email', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_requiredFieldsError != null) {
                        setState(() {
                          _requiredFieldsError = null;
                        });
                      }
                    },
                    enabled: !authState.isLoading,
                    decoration: InputDecoration(
                      hintText: 'email@gmail.com',
                      prefixIcon: Icon(
                        Icons.alternate_email_rounded,
                        color: hasValidationError ? AppColors.red300 : null,
                      ),
                      suffixIcon: hasValidationError
                          ? const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.red300,
                            )
                          : null,
                      enabledBorder: hasValidationError ? errorBorder : null,
                      focusedBorder: hasValidationError ? errorBorder : null,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text('Senha', style: textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) {
                      if (_requiredFieldsError != null) {
                        setState(() {
                          _requiredFieldsError = null;
                        });
                      }
                    },
                    onSubmitted: (_) => _submit(),
                    enabled: !authState.isLoading,
                    decoration: InputDecoration(
                      hintText: '************',
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: hasValidationError ? AppColors.red300 : null,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: hasValidationError
                                  ? AppColors.red300
                                  : null,
                            ),
                          ),
                          if (hasValidationError)
                            const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.red300,
                              ),
                            ),
                        ],
                      ),
                      enabledBorder: hasValidationError ? errorBorder : null,
                      focusedBorder: hasValidationError ? errorBorder : null,
                    ),
                  ),
                  const SizedBox(height: 45),
                  AppButton(
                    label: authState.isLoading ? 'Entrando...' : 'Entrar',
                    onPressed: _submit,
                    isLoading: authState.isLoading,
                    mainAxisSize: MainAxisSize.min,
                  ),
                  const SizedBox(height: 45),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nao tem uma conta?', style: textTheme.bodyMedium),
                      TextButton(
                        onPressed: _onRegisterTap,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.blue200,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Cadastre-se!',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.blue200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
