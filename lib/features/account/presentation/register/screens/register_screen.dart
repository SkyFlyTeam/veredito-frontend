import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../routes/app_router.dart';
import '../../../../../shared/widgets/app_logo.dart';
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 35,
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
                style: textTheme.bodyMedium?.copyWith(color: AppColors.blue200),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
