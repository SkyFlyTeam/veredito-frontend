import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/providers/session_provider.dart';
import 'package:flutter_cookiecutter/shared/widgets/app_logo.dart';
import 'package:flutter_cookiecutter/core/theme/app_colors.dart';
import '../providers/legal_case_home_provider.dart';
import '../widgets/legal_case_form.dart';

class LegalCaseHomeScreen extends ConsumerWidget {
  const LegalCaseHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final notifier = ref.read(legalCaseHomeProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    ref.listen(legalCaseHomeProvider, (previous, next) {
      if (next.isSuccess && !(previous?.isSuccess ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Caso jurídico criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        notifier.reset();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: AppLogo(isHorizontal: true, iconHeight: 24)),
          const SizedBox(height: 32),
          Text(
            'Olá, ${user?.nome ?? ''}!',
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            'Comece a analisar novos documentos.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.purple100,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 36),
          const LegalCaseFormCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
