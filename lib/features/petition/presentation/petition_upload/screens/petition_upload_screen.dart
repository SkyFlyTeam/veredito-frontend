import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/providers/session_provider.dart';
import 'package:flutter_cookiecutter/shared/widgets/app_logo.dart';
import 'package:flutter_cookiecutter/features/analysis/presentation/shared/widgets/common_upload_card.dart';

class PetitionUploadScreen extends ConsumerWidget {
  const PetitionUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
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
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 35),
          const CommonUploadCard(
            title: 'Enviar Petição Inicial',
          ),
        ],
      ),
    );
  }
}
