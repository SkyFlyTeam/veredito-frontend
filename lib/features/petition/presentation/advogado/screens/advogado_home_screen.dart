import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cookiecutter/core/theme/app_colors.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/providers/session_provider.dart';
import 'package:flutter_cookiecutter/shared/widgets/app_logo.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/shared/widgets/common_upload_card.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/petition_upload/providers/petition_upload_provider.dart';

class AdvogadoHomeScreen extends ConsumerWidget {
  const AdvogadoHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: AppLogo(isHorizontal: true, iconHeight: 24)),
          const SizedBox(height: 32),
          Text(
            'Olá, ${user?.nome ?? ''} Advogado!',
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            'Prepare suas novas petições',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.purple200,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 35),
          CommonUploadCard(
            title: 'Enviar Petição Inicial',
          ),
        ],
      ),
    );
  }
}
