import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../data/models/peticao_document.dart';

class PetitionUploadCard extends StatefulWidget {
  /// Called with the assembled [PeticaoDocument] once the simulated
  /// upload reaches 100%. Use this to persist the document and switch tabs.
  final void Function(PeticaoDocument document)? onUploadComplete;

  /// Called when the user taps "Analisar petição >". Fires after onUploadComplete.
  final VoidCallback? onAnalyze;

  /// Called whenever the error state changes so the parent can show/hide
  /// an error banner without affecting the card's own layout.
  final void Function(bool hasError)? onErrorChanged;

  /// Allows tests to inject a fake file picker without touching the platform.
  /// In production this is null and the real FilePicker is used.
  final Future<String?> Function()? onPickFile;

  const PetitionUploadCard({
    super.key,
    this.onUploadComplete,
    this.onAnalyze,
    this.onErrorChanged,
    this.onPickFile,
  });

  @override
  State<PetitionUploadCard> createState() => _PetitionUploadCardState();
}

const _allowedExtensions = {'pdf', 'docx', 'txt'};

class _PetitionUploadCardState extends State<PetitionUploadCard> {
  String? _fileName;
  double _progress = 0;
  bool _isDone = false;
  bool _isAnalyzing = false;
  Timer? _timer;
  /// Opens the file picker and captures only the file name.
  /// No content is read or sent — simulates the flow without a backend.
  /// On the emulator, select the file "example-1.docx" from the Downloads folder.
  Future<void> _pickFile() async {
    final String? picked;
    if (widget.onPickFile != null) {
      picked = await widget.onPickFile!();
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: false,
        withReadStream: false,
      );
      picked =
          (result != null && result.files.isNotEmpty)
              ? result.files.first.name
              : null;
    }
    if (picked == null || !mounted) return;

    final ext = picked.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      widget.onErrorChanged?.call(true);
      return;
    }

    setState(() {
      _fileName = picked;
      _progress = 0;
      _isDone = false;
    });
    widget.onErrorChanged?.call(false);
    _simulateUpload();
  }

  void _simulateUpload() {
    _timer?.cancel();
    _isDone = false;
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_progress >= 1.0) {
        timer.cancel();
        setState(() => _isDone = true);
        _scheduleAutoReset();
        return;
      }
      setState(() => _progress += 0.01);
    });
  }

  void _scheduleAutoReset() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || !_isDone) return;
      _doReset();
    });
  }

  void _doReset() {
    final completedFile = _fileName;
    if (completedFile != null) {
      final dotIndex = completedFile.lastIndexOf('.');
      final name =
          dotIndex != -1 ? completedFile.substring(0, dotIndex) : completedFile;
      final ext =
          dotIndex != -1 ? completedFile.substring(dotIndex + 1) : '';
      final doc = PeticaoDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: name,
        extension: ext,
        uploadedAt: DateTime.now(),
      );
      widget.onUploadComplete?.call(doc);
    }
    setState(() {
      _fileName = null;
      _progress = 0;
      _isDone = false;
      _isAnalyzing = false;
    });
    widget.onErrorChanged?.call(false);
    widget.onAnalyze?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleAnalyze() {
    if (_isAnalyzing || !_isDone) return;
    setState(() => _isAnalyzing = true);
    _doReset();
  }

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTap: (_fileName == null || _isDone) ? _pickFile : null,
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

    if (_isDone) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          card,
          const SizedBox(height: 10),
          SizedBox(
            width: 304,
            height: 41,
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : _handleAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple200,
                disabledBackgroundColor: AppColors.purple200.withValues(alpha: 0.6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Center(
                child: _isAnalyzing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Analisar petição',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
              ),
            ),
          ),
        ],
      );
    }

    return card;
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
