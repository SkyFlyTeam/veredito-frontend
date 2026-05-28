import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/bottom_sheet.dart';
import '../../../domain/entities/precedent_suggested.dart';

class SentenceModal extends StatefulWidget {
  final List<PrecedentSuggested> suggestions;
  final Future<void> Function(String text)? onSave;

  const SentenceModal({super.key, required this.suggestions, this.onSave});

  static Future<T?> show<T>(
    BuildContext context, {
    required List<PrecedentSuggested> suggestions,
    Future<void> Function(String text)? onSave,
  }) {
    return AppBottomSheet.show<T>(
      context,
      bodyBuilder: (_) =>
          SentenceModal(suggestions: suggestions, onSave: onSave),
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
  late final Set<int> _selectedIds;
  bool _isSaving = false;

  List<PrecedentSuggested> get _selectedSuggestions {
    return widget.suggestions
        .where((suggestion) => _selectedIds.contains(suggestion.id))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.suggestions.map((p) => p.id).toSet();
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
    buffer.writeln('MINUTA DE SENTENCA\n');
    buffer.writeln(
      'Com base nos precedentes analisados, segue a minuta de sentenca:\n',
    );

    for (final suggestion in widget.suggestions) {
      buffer.writeln('${suggestion.title} (${suggestion.tribunalSigla})');
      if (suggestion.hasSinteseExplicativa) {
        buffer.writeln('  ${suggestion.sinteseExplicativaText}\n');
      }
    }

    buffer.writeln('\nDecisao:\n\n[Insira o texto da decisao aqui]');
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

  void _toggleSuggestion(int id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
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
            'Minuta de Sentenca',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.gray100,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          if (widget.suggestions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${_selectedIds.length} precedente${_selectedIds.length == 1 ? '' : 's'} selecionado${_selectedIds.length == 1 ? '' : 's'}',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.gray300,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 20),
          _PrecedentChips(suggestions: _selectedSuggestions),
          if (widget.suggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _PrecedentSelector(
              suggestions: widget.suggestions,
              selectedIds: _selectedIds,
              textTheme: textTheme,
              onToggle: _toggleSuggestion,
            ),
          ],
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
            (suggestion) => _PrecedentChip(
              label: suggestion.tribunalSigla,
              similarity: suggestion.percentualSimilaridadePercentage,
              color: suggestion.classificationColor,
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
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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

class _PrecedentSelector extends StatelessWidget {
  final List<PrecedentSuggested> suggestions;
  final Set<int> selectedIds;
  final TextTheme textTheme;
  final void Function(int id, bool selected) onToggle;

  const _PrecedentSelector({
    required this.suggestions,
    required this.selectedIds,
    required this.textTheme,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 190),
      child: SingleChildScrollView(
        child: Column(
          children: suggestions
              .map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PrecedentRow(
                    precedent: suggestion,
                    textTheme: textTheme,
                    isSelected: selectedIds.contains(suggestion.id),
                    onToggle: (selected) => onToggle(suggestion.id, selected),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _PrecedentRow extends StatelessWidget {
  final PrecedentSuggested precedent;
  final TextTheme textTheme;
  final bool isSelected;
  final ValueChanged<bool> onToggle;

  const _PrecedentRow({
    required this.precedent,
    required this.textTheme,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.purple200.withValues(alpha: 0.15)
              : AppColors.gray200.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.purple200.withValues(alpha: 0.4)
                : AppColors.gray100.withValues(alpha: 0.15),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: isSelected,
                onChanged: (value) => onToggle(value ?? false),
                activeColor: AppColors.purple200,
                checkColor: AppColors.gray100,
                side: BorderSide(
                  color: AppColors.gray100.withValues(alpha: 0.4),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    precedent.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.gray100,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    precedent.tribunalSigla,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.blue50,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextTheme textTheme;

  const _DraftTextField({required this.controller, required this.textTheme});

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
          hintText: 'Texto da minuta de sentenca...',
          hintStyle: textTheme.bodySmall?.copyWith(
            color: AppColors.gray300,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
