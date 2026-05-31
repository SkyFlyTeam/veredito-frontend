import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../analysis/domain/entities/secao_peticao.dart';
import '../../../../analysis/presentation/legal_case/widgets/section_card.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/file_name_parser.dart';
import '../../../../petition/domain/entities/peticao.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../providers/minuta_peticao_provider.dart';
import '../view_models/minuta_peticao_state.dart';
import '../widget/analysis_section_title.dart';
import '../widget/animated_skeleton_block.dart';

class MinutaPeticaoScreen extends ConsumerStatefulWidget {
  final Peticao peticao;

  const MinutaPeticaoScreen({super.key, required this.peticao});

  @override
  ConsumerState<MinutaPeticaoScreen> createState() =>
      _MinutaPeticaoScreenState();
}

class _MinutaPeticaoScreenState extends ConsumerState<MinutaPeticaoScreen> {
  late final MinutaPeticaoState _initialState;

  @override
  void initState() {
    super.initState();
    _initialState = MinutaPeticaoState.initial(widget.peticao);

    // Trigger initialization after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(minutaPeticaoViewModelProvider(_initialState).notifier)
          .initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(minutaPeticaoViewModelProvider(_initialState));
    final viewModel = ref.read(
      minutaPeticaoViewModelProvider(_initialState).notifier,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context, textTheme),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Arquivo ──────────────────────────────────────────────────
              AnalysisSectionTitle(
                title: 'Analisando Arquivo',
                textTheme: textTheme,
              ),
              const SizedBox(height: 12),
              _FileCard(peticao: widget.peticao),
              const SizedBox(height: 28),

              // ── Seções da Petição ─────────────────────────────────────────
              AnalysisSectionTitle(
                title: 'Minuta de Petição',
                textTheme: textTheme,
              ),
              const SizedBox(height: 4),
              Text(
                'Edite as seções conforme necessário antes de finalizar.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.gray300,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),

              if (state.isLoading)
                const _SectionsSkeleton()
              else if (state.errorMessage != null)
                _ErrorCard(message: state.errorMessage!)
              else if (state.secoes == null || state.secoes!.isEmpty)
                _EmptyCard(textTheme: textTheme)
              else
                _SectionsList(
                  secoes: state.secoes!,
                  onEdit: viewModel.updateSecao,
                ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, TextTheme textTheme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.gray800.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.gray100,
            size: 18,
          ),
        ),
      ),
      title: Text(
        'Minuta de Petição',
        style: GoogleFonts.montserrat(
          color: AppColors.gray100,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FileCard extends StatelessWidget {
  final Peticao peticao;

  const _FileCard({required this.peticao});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fileName = extractOriginalFileNameFromPath(peticao.caminhoArquivo);

    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.insert_drive_file_rounded,
              size: 34,
              color: AppColors.gray100,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray100,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionsList extends StatelessWidget {
  final List<SecaoPeticao> secoes;
  final void Function(SecaoPeticao secaoEditada) onEdit;

  const _SectionsList({required this.secoes, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < secoes.length; i++) ...[
          SectionCard(
            secao: secoes[i],
            onEdit: onEdit,
          ),
          if (i < secoes.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _SectionsSkeleton extends StatelessWidget {
  const _SectionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => _SkeletonCard(index: index)),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final int index;

  const _SkeletonCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: index < 2 ? 16 : 0),
      child: GlassCard(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title skeleton
              AnimatedSkeletonBlock(
                width: 140,
                height: 14,
                borderRadius: 7,
              ),
              const SizedBox(height: 12),
              // Content skeleton
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gray100.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSkeletonBlock(
                      width: double.infinity,
                      height: 11,
                      borderRadius: 5,
                    ),
                    const SizedBox(height: 8),
                    AnimatedSkeletonBlock(
                      width: double.infinity,
                      height: 11,
                      borderRadius: 5,
                    ),
                    const SizedBox(height: 8),
                    AnimatedSkeletonBlock(
                      width: 200,
                      height: 11,
                      borderRadius: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.red300,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.red300,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final TextTheme textTheme;

  const _EmptyCard({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Text(
          'Nenhuma seção gerada para esta petição.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.gray100,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
