import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/bottom_sheet.dart';
import '../../../domain/entities/precedent_suggested.dart';


class SentenceModal extends StatefulWidget {
  final List<PrecedentSuggested> suggestions;
  final Future<void> Function(
    String text,
    List<PrecedentSuggested> selectedSuggestions,
  )?
  onSave;

  const SentenceModal({super.key, required this.suggestions, this.onSave});

  static Future<T?> show<T>(
    BuildContext context, {
    required List<PrecedentSuggested> suggestions,
    Future<void> Function(
      String text,
      List<PrecedentSuggested> selectedSuggestions,
    )?
    onSave,
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
  late final Set<int> _selectedPrecedentIds;
  bool _isSaving = false;

  List<PrecedentSuggested> get _selectedSuggestions {
    return widget.suggestions
      .where(
        (suggestion) =>
          _selectedPrecedentIds.contains(suggestion.precedentId),
      )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedPrecedentIds =
        widget.suggestions.map((p) => p.precedentId).toSet();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave?.call(_controller.text, _selectedSuggestions);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toggleSuggestion(int id, bool selected) {
    setState(() {
      if (selected) {
        _selectedPrecedentIds.add(id);
      } else {
        _selectedPrecedentIds.remove(id);
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
            'Gerar Minuta de Sentenca',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.gray100,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          _DraftTextField(controller: _controller, textTheme: textTheme),
          if (widget.suggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Precedentes para fundamentacao:',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.gray100,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            _PrecedentSelector(
              suggestions: widget.suggestions,
              selectedIds: _selectedPrecedentIds,
              textTheme: textTheme,
              onToggle: _toggleSuggestion,
            ),
          ],
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
                    isSelected:
                        selectedIds.contains(suggestion.precedentId),
                    onToggle: (selected) =>
                        onToggle(suggestion.precedentId, selected),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dispositivo',
          style: TextStyle(
            color: AppColors.gray100,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
              hintText: 'Exemplo: Ante o exposto, julgo procedente o pedido da autora, condenando o réu ao pagamento de indenização',
              hintStyle: textTheme.bodySmall?.copyWith(
                color: AppColors.gray300,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
