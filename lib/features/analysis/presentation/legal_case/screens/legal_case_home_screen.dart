import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/providers/session_provider.dart';
import 'package:flutter_cookiecutter/shared/widgets/app_logo.dart';
import 'package:flutter_cookiecutter/core/theme/app_colors.dart';
import 'package:toastification/toastification.dart';
import '../providers/legal_case_home_provider.dart';
import '../widgets/legal_case_form.dart';

class LegalCaseHomeScreen extends ConsumerWidget {
  const LegalCaseHomeScreen({super.key});

  void _showSuccessToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      title: const Text('Sucesso'),
      description: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final state = ref.watch(legalCaseHomeProvider);
    final notifier = ref.read(legalCaseHomeProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    ref.listen(legalCaseHomeProvider, (previous, next) {
      if (next.isSuccess && !(previous?.isSuccess ?? false)) {
        final createdCase = next.createdCase;
        if (createdCase == null) return;

        _showSuccessToast(context, 'Caso jurídico criado com sucesso!');
        notifier.reset();
        Navigator.pushReplacementNamed(
          context,
          '/minuta_peticao',
          arguments: createdCase,
        );
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
          LegalCaseFormCard(key: ValueKey(state.formResetToken ?? 0)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
