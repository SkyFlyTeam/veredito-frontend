import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../core/theme/app_colors.dart';

class FileInput extends StatefulWidget {
  final List<String> acceptedExtensions;
  final bool multiple;
  final FutureOr<void> Function(List<PlatformFile> files) onUpload;
  final FutureOr<void> Function(List<PlatformFile> files) onDelete;

  const FileInput({
    super.key,
    required this.acceptedExtensions,
    required this.multiple,
    required this.onUpload,
    required this.onDelete,
  });

  @override
  State<FileInput> createState() => _FileInputState();
}

class _FileInputState extends State<FileInput> {
  static const int _maxFiles = 3;
  final List<PlatformFile> _selectedFiles = <PlatformFile>[];
  bool _isBusy = false;

  Future<void> _pickFiles() async {
    if (_isBusy) return;

    final pickerResult = await FilePicker.platform.pickFiles(
      allowMultiple: widget.multiple,
      type: widget.acceptedExtensions.isEmpty ? FileType.any : FileType.custom,
      allowedExtensions: widget.acceptedExtensions.isEmpty
          ? null
          : widget.acceptedExtensions
                .map(
                  (extension) => extension.toLowerCase().replaceFirst('.', ''),
                )
                .toList(),
      withData: true,
    );

    if (!mounted || pickerResult == null || pickerResult.files.isEmpty) {
      return;
    }

    final pickedFiles = widget.multiple
        ? pickerResult.files
        : <PlatformFile>[pickerResult.files.first];

    final nextFiles = widget.multiple
        ? _mergeFiles(_selectedFiles, pickedFiles)
        : pickedFiles;

    final validationError = _validateFiles(nextFiles);
    if (validationError != null) {
      _showErrorToast(validationError);
      return;
    }

    setState(() {
      _selectedFiles
        ..clear()
        ..addAll(nextFiles);
    });

    try {
      _isBusy = true;
      await widget.onUpload(List<PlatformFile>.unmodifiable(_selectedFiles));
    } catch (_) {
      if (!mounted) return;
      _showErrorToast('Não foi possível enviar o arquivo selecionado.');
      return;
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _deleteFiles() async {
    if (_isBusy || _selectedFiles.isEmpty) return;

    final filesToDelete = List<PlatformFile>.from(_selectedFiles);

    try {
      _isBusy = true;
      await widget.onDelete(List<PlatformFile>.unmodifiable(filesToDelete));
      if (!mounted) return;
      setState(_selectedFiles.clear);
    } catch (_) {
      if (!mounted) return;
      _showErrorToast('Não foi possível excluir o arquivo selecionado.');
    } finally {
      _isBusy = false;
    }
  }

  String? _validateFiles(List<PlatformFile> files) {
    if (widget.multiple && files.length > _maxFiles) {
      return 'Máximo de $_maxFiles documentos permitidos.';
    }

    if (widget.acceptedExtensions.isEmpty) {
      return null;
    }

    final allowedExtensions = widget.acceptedExtensions
        .map((extension) => extension.toLowerCase().replaceFirst('.', ''))
        .toSet();

    for (final file in files) {
      final extension = _extractExtension(file.name);
      if (extension.isEmpty || !allowedExtensions.contains(extension)) {
        return 'Arquivo inválido. Extensões permitidas: ${_formatExtensions(widget.acceptedExtensions)}.';
      }
    }

    return null;
  }

  List<PlatformFile> _mergeFiles(
    List<PlatformFile> currentFiles,
    List<PlatformFile> newFiles,
  ) {
    final mergedFiles = <PlatformFile>[...currentFiles];

    for (final file in newFiles) {
      final alreadySelected = mergedFiles.any(
        (selected) => selected.name == file.name && selected.size == file.size,
      );
      if (!alreadySelected) {
        mergedFiles.add(file);
      }
    }

    return mergedFiles;
  }

  String _extractExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }

    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  String _formatExtensions(List<String> extensions) {
    final normalized = extensions
        .map((extension) => extension.toUpperCase().replaceFirst('.', ''))
        .toList();

    if (normalized.isEmpty) {
      return '';
    }
    if (normalized.length == 1) {
      return normalized.first;
    }
    if (normalized.length == 2) {
      return '${normalized.first} ou ${normalized.last}';
    }

    return '${normalized.sublist(0, normalized.length - 1).join(', ')} ou ${normalized.last}';
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: const Text('Erro'),
      description: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFiles = _selectedFiles.isNotEmpty;
    final displayedText = hasFiles
        ? widget.multiple
              ? '${_selectedFiles.length} arquivo${_selectedFiles.length == 1 ? '' : 's'}'
              : _selectedFiles.first.name
        : 'Clique para carregar um arquivo';

    final supportingText = widget.acceptedExtensions.isEmpty
        ? null
        : _formatExtensions(widget.acceptedExtensions);

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isBusy ? null : _pickFiles,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: AppColors.gray300.withValues(alpha: 1),
            borderRadius: 15,
          ),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 80),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.purple700.withValues(alpha: 0.90),
                  AppColors.purple800.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.file_upload_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayedText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      if (supportingText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          supportingText,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.purple100,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasFiles) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _isBusy ? null : _deleteFiles,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.red300,
                    ),
                    tooltip: 'Excluir arquivo',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  _DashedBorderPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1),
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 14.0;
    const dashSpace = 10.0;

    for (final path in _buildDashedPath(rrect, dashWidth, dashSpace)) {
      canvas.drawPath(path, paint);
    }
  }

  List<Path> _buildDashedPath(RRect rrect, double dashWidth, double dashSpace) {
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics(forceClosed: true);
    final dashedPaths = <Path>[];

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final currentDash = dashWidth;
        dashedPaths.add(metric.extractPath(distance, distance + currentDash));
        distance += currentDash + dashSpace;
      }
    }

    return dashedPaths;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}
