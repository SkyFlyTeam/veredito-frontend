import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../data/models/peticao_document.dart';

class PetitionDocumentCard extends StatelessWidget {
  final PeticaoDocument document;

  const PetitionDocumentCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.blue800.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gray300.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _FileIcon(extension: document.extension),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${document.fileName}.${document.extension}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(document.uploadedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray300,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}

class _FileIcon extends StatelessWidget {
  final String extension;

  const _FileIcon({required this.extension});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (extension.toLowerCase()) {
      'pdf' => (Icons.picture_as_pdf_outlined, AppColors.red300),
      'docx' || 'doc' => (Icons.article_outlined, AppColors.blue300),
      'txt' => (Icons.text_snippet_outlined, AppColors.gray300),
      _ => (Icons.insert_drive_file_outlined, AppColors.gray300),
    };

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
