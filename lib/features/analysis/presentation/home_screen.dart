import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_router.dart';
import '../../account/domain/entities/user.dart';
import '../../account/presentation/login/providers/session_provider.dart';
import '../../../shared/widgets/app_logo.dart';
import 'shared/widgets/analysis_item_card.dart';
import 'shared/widgets/common_upload_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final textTheme = Theme.of(context).textTheme;

    final isJuiz = user?.isJuiz ?? false;

    final subtitle = isJuiz
        ? 'Comece a analisar novos documentos'
        : 'Prepare suas novas petições';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
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
            subtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.purple100,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 36),
          if (isJuiz) ...[
            AnalysisItemCard(
              name: 'Petição inicial',
              description:
                  'Gerar síntese da petição e buscar precedentes aderentes',
              onTap: () => Navigator.pushNamed(
                context,
                AppRouter.precedentAnalysis,
              ),
            ),
            const SizedBox(height: 25),
            AnalysisItemCard(
              name: 'Processos',
              description:
                  'Analisar processo completo e buscar precedentes aderentes',
              onTap: () => (Navigator.pushNamed(
                context,
                AppRouter.newProcessAnalysis,
              )),
            ),
          ] else ...[
            const CommonUploadCard(title: 'Enviar Petição Inicial'),
          ],
        ],
      ),
    );
  }
}
