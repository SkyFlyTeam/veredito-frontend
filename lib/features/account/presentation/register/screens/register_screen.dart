import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../routes/app_router.dart';
import '../../../../../shared/widgets/app_logo.dart';
import '../providers/register_usecase_provider.dart';
import '../widgets/register_form.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  void _onLoginTap() {
    Navigator.of(context).pushReplacementNamed(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    ref.listen(registerViewModelProvider, (previous, next) {
      final finishedLoading = (previous?.isLoading ?? false) && !next.isLoading;
      final registerSucceeded = next.error == null;

      if (finishedLoading && registerSucceeded) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: const Text("Usuário cadastrado com sucesso!"),
          description: Text(
            "Bem-vindo ao Veredito, faça login para continuar.",
          ),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
        );
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 40,
              children: [
                AppLogo(isHorizontal: false),
                const RegisterForm(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Já tem uma conta?', style: textTheme.bodyMedium),
                    TextButton(
                      onPressed: _onLoginTap,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.blue200,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Faça login!',
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
    );
  }
}
