import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../routes/app_router.dart';
import '../../../../../shared/layouts/page_layout.dart';
import '../providers/login_usecase_provider.dart';
import '../widgets/login_form.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(loginViewModelProvider, (previous, next) {
      final finishedLoading = (previous?.isLoading ?? false) && !next.isLoading;
      final loginSucceeded = next.error == null;

      if (finishedLoading && loginSucceeded) {
        Navigator.of(context).pushReplacementNamed(AppRouter.home);
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageLayout(child: LoginForm()),
    );
  }
}
