import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class PetitionUploadCard extends StatefulWidget {
  /// Called with the file name (e.g. "peticao.pdf") once the simulated
  /// upload reaches 100%. Use this to persist the document and switch tabs.
  final void Function(String fileName)? onUploadComplete;

  /// Allows tests to inject a fake file picker without touching the platform.
  /// In production this is null and the real FilePicker is used.
  final Future<String?> Function()? onPickFile;

  const PetitionUploadCard({super.key, this.onUploadComplete, this.onPickFile});

  @override
  State<PetitionUploadCard> createState() => _PetitionUploadCardState();
}

class _PetitionUploadCardState extends State<PetitionUploadCard> {
  String? _fileName;
  double _progress = 0;
  bool _isDone = false;
  Timer? _timer;

  /// Abre o seletor de arquivos e captura apenas o nome do arquivo.
  /// Nenhum conteúdo é lido ou enviado — simulação de fluxo sem backend.
  /// No emulador, selecione o arquivo "example-1.docx" na pasta Downloads.
  Future<void> _pickFile() async {
    final String? picked;
    if (widget.onPickFile != null) {
      picked = await widget.onPickFile!();
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        withData: false,
        withReadStream: false,
      );
      picked =
          (result != null && result.files.isNotEmpty)
              ? result.files.first.name
              : null;
    }
    if (picked == null || !mounted) return;
    setState(() {
      _fileName = picked;
      _progress = 0;
      _isDone = false;
    });
    _simulateUpload();
  }

  void _simulateUpload() {
    _timer?.cancel();
    _isDone = false;
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_progress >= 1.0) {
        timer.cancel();
        setState(() => _isDone = true);
        final completedFile = _fileName;
        // Aguarda 2s para o usuário ver o estado "Concluído" e então
        // reseta o card e notifica o listener (que troca de aba).
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _fileName = null;
              _progress = 0;
              _isDone = false;
            });
          }
          if (completedFile != null) {
            widget.onUploadComplete?.call(completedFile);
          }
        });
        return;
      }
      setState(() => _progress += 0.01);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _fileName == null ? _pickFile : null,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.gray300.withValues(alpha: 0.6),
          borderRadius: 16,
        ),
        child: SizedBox(
          width: 290,
          height: 279,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blue800.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _fileName == null
                ? _buildIdle(context)
                : _isDone
                    ? _buildDone(context)
                    : _buildUploading(context),
          ),
        ),
      ),
    );
  }

  Widget _buildIdle(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 75,
          left: 121,
          width: 47,
          height: 47,
          child: Icon(
            Icons.file_upload_outlined,
            color: Colors.white,
            size: 47,
          ),
        ),
        Positioned(
          top: 152,
          left: 50,
          width: 189,
          height: 15,
          child: Text(
            'Clique para fazer upload',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Positioned(
          top: 199,
          left: 49,
          width: 189,
          height: 12,
          child: Text(
            'PDF, DOCX ou TXT',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.purple300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploading(BuildContext context) {
    final percent = (_progress * 100).toInt();
    return Stack(
      children: [
        const Positioned(
          top: 75,
          left: 121,
          width: 47,
          height: 47,
          child: Icon(
            Icons.insert_drive_file_outlined,
            color: Colors.white,
            size: 47,
          ),
        ),
        Positioned(
          top: 152,
          left: 20,
          width: 250,
          height: 15,
          child: Text(
            _fileName!,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Positioned(
          top: 225,
          left: 20,
          child: Text(
            'Fazendo upload...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
        Positioned(
          top: 225,
          right: 20,
          child: Text(
            '$percent%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
        Positioned(
          top: 243,
          left: 20,
          right: 20,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.blue300.withValues(alpha: 0.3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.blue300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 75,
          left: 121,
          width: 47,
          height: 47,
          child: Icon(
            Icons.insert_drive_file_outlined,
            color: Colors.white,
            size: 47,
          ),
        ),
        Positioned(
          top: 152,
          left: 20,
          width: 250,
          height: 15,
          child: Text(
            _fileName!,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Positioned(
          top: 225,
          left: 20,
          child: Text(
            'Concluído',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
        Positioned(
          top: 225,
          right: 20,
          child: Text(
            '100%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
        Positioned(
          top: 243,
          left: 20,
          right: 20,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: const LinearProgressIndicator(
              value: 1.0,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.green400),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  static const double _dashWidth = 8;
  static const double _dashSpace = 6;
  static const double _strokeWidth = 1.5;

  final Color color;
  final double borderRadius;

  const _DashedBorderPainter({
    required this.color,
    this.borderRadius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + _dashWidth).clamp(0.0, metric.length);
        dashedPath.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += _dashWidth + _dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}
