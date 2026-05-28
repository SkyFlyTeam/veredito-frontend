import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/bottom_sheet.dart';
import '../../../domain/entities/precedent_suggested.dart';

class SentenceModal extends StatefulWidget {
  final List<PrecedentSuggested> suggestions;
  final Future<void> Function(String text)? onSave;

  const SentenceModal({
    super.key,
    required this.suggestions,
    this.onSave,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required List<PrecedentSuggested> suggestions,
    Future<void> Function(String text)? onSave,
  }) {
    return AppBottomSheet.show<T>(
      context,
      bodyBuilder: (_) => SentenceModal(suggestions: suggestions, onSave: onSave),
      maxHeightFactor: 0.92,
      heightBuffer: 72,
      backgroundColor: AppColors.blue900,
      borderColor: AppColors.gray200.withValues(alpha: 0.7),
    );
  }

  @override
  State<SentenceModal> createState() => _SentenceModalState();
}

class _SentenceModalState extends State<SentenceModal> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _buildDraftText());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _buildDraftText() {
    if (widget.suggestions.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('MINUTA DE SENTENÇA\n');
    buffer.writeln(
      'Com base nos precedentes analisados, segue a minuta de sentença:\n',
    );

    for (final s in widget.suggestions) {
      buffer.writeln('• ${s.title} (${s.tribunalSigla})');
      if (s.hasSinteseExplicativa) {
        buffer.writeln('  ${s.sinteseExplicativaText}\n');
      }
    }

    buffer.writeln('\nDecisão:\n\n[Insira o texto da decisão aqui]');
    return buffer.toString();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave?.call(_controller.text);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Minuta de Sentença',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.gray100,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -0.4,
            ),
          ),
          if (widget.suggestions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${widget.suggestions.length} precedente${widget.suggestions.length == 1 ? '' : 's'} selecionado${widget.suggestions.length == 1 ? '' : 's'}',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.gray300,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 20),
          _PrecedentChips(suggestions: widget.suggestions),
          const SizedBox(height: 16),
          _DraftTextField(controller: _controller, textTheme: textTheme),
          const SizedBox(height: 20),
          AppButton(
            label: 'Salvar minuta',
            onPressed: _handleSave,
            isLoading: _isSaving,
            mainAxisSize: MainAxisSize.max,
          ),
        ],
      ),
    );
  }
}

class _PrecedentChips extends StatelessWidget {
  final List<PrecedentSuggested> suggestions;

  const _PrecedentChips({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions
          .map(
            (s) => _PrecedentChip(
              label: s.tribunalSigla,
              similarity: s.percentualSimilaridadePercentage,
              color: s.classificationColor,
            ),
          )
          .toList(),
    );
  }
}

class _PrecedentChip extends StatelessWidget {
  final String label;
  final String similarity;
  final Color color;

  const _PrecedentChip({
    required this.label,
    required this.similarity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.purple200.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.gray100,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            similarity,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.gray300,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextTheme textTheme;

  const _DraftTextField({
    required this.controller,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.purple100.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gray200.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: 12,
        minLines: 8,
        style: textTheme.bodySmall?.copyWith(
          color: AppColors.gray100,
          fontSize: 12,
          height: 1.6,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(14),
          border: InputBorder.none,
          hintText: 'Texto da minuta de sentença...',
          hintStyle: textTheme.bodySmall?.copyWith(
            color: AppColors.gray300,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
