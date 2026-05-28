import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../features/analysis/domain/entities/secao_peticao.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/glass_card.dart';

class SectionCard extends StatelessWidget {
  final SecaoPeticao secao;
  final void Function(SecaoPeticao secaoEditada) onEdit;

  const SectionCard({
    super.key,
    required this.secao,
    required this.onEdit,
  });

  void _openEditModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _SectionEditModal(
        secao: secao,
        onSave: (secaoEditada) {
          onEdit(secaoEditada);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    secao.titulo,
                    style: const TextStyle(
                      color: AppColors.gray100,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _openEditModal(context),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.gray100,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.gray100,
                  width: 1,
                ),
              ),
              child: Text(
                secao.conteudo,
                style: const TextStyle(
                  color: AppColors.gray100,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
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

class _SectionEditModal extends StatefulWidget {
  final SecaoPeticao secao;
  final void Function(SecaoPeticao secaoEditada) onSave;

  const _SectionEditModal({
    required this.secao,
    required this.onSave,
  });

  @override
  State<_SectionEditModal> createState() => _SectionEditModalState();
}

class _SectionEditModalState extends State<_SectionEditModal> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.secao.conteudo);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    final secaoEditada = SecaoPeticao(
      id: widget.secao.id,
      titulo: widget.secao.titulo,
      conteudo: _controller.text,
    );
    widget.onSave(secaoEditada);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.gray700,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.secao.titulo,
                      style: GoogleFonts.montserrat(
                        color: AppColors.gray900,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.gray900,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                maxLines: 8,
                minLines: 5,
                style: const TextStyle(
                  color: AppColors.gray900,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Digite o conteúdo da seção...',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.gray900),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.gray900),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Salvar',
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
