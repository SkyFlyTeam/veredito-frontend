import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../data/models/peticao_document.dart';

class PetitionUploadCard extends StatefulWidget {
  
  final void Function(PeticaoDocument document)? onUploadComplete;

  
  final VoidCallback? onAnalyze;

  
  final void Function(bool hasError)? onErrorChanged;

  
  final Future<String?> Function()? onPickFile;

  
  final Future<void> Function(
    String fileName,
    List<int> bytes,
    void Function(double) onProgress,
  )? onUploadFile;

  const PetitionUploadCard({
    super.key,
    this.onUploadComplete,
    this.onAnalyze,
    this.onErrorChanged,
    this.onPickFile,
    this.onUploadFile,
  });

  @override
  State<PetitionUploadCard> createState() => _PetitionUploadCardState();
}

const _allowedExtensions = {'pdf', 'docx', 'txt'};

class _PetitionUploadCardState extends State<PetitionUploadCard> {
  String? _fileName;
  List<int>? _fileBytes;
  bool _isFileSelected = false;
  double _progress = 0;
  bool _isUploading = false;
  bool _isDone = false;
  bool _isAnalyzing = false;

  Future<void> _pickFile() async {
    final String? pickedName;
    List<int>? pickedBytes;

    if (widget.onPickFile != null) {
      pickedName = await widget.onPickFile!();
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        pickedName = result.files.first.name;
        pickedBytes = result.files.first.bytes?.toList();
      } else {
        pickedName = null;
      }
    }

    if (pickedName == null || !mounted) return;

    final ext = pickedName.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      widget.onErrorChanged?.call(true);
      return;
    }

    widget.onErrorChanged?.call(false);
    setState(() {
      _fileName = pickedName;
      _fileBytes = pickedBytes;
      _isFileSelected = true;
      _progress = 0;
      _isUploading = false;
      _isDone = false;
    });
  }

  Future<void> _handleUpload() async {
    if (_isUploading || _isDone) return;
    setState(() {
      _isUploading = true;
      _isFileSelected = false;
      _progress = 0;
    });

    // Garante tempo mínimo de exibição da barra — uploads locais são tão
    // rápidos que a UI pularia direto para o estado concluído sem animar.
    final minDisplay = Future.delayed(const Duration(milliseconds: 800));

    try {
      await widget.onUploadFile?.call(
        _fileName!,
        _fileBytes ?? [],
        (progress) {
          if (mounted) setState(() => _progress = progress);
        },
      );
      await minDisplay;
      if (!mounted) return;
      // Preenche a barra suavemente até 100% antes de mostrar "Concluído".
      setState(() => _progress = 1.0);
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        _isDone = true;
        _isUploading = false;
      });
      _scheduleAutoReset();
    } catch (_) {
      await minDisplay;
      if (!mounted) return;
      widget.onErrorChanged?.call(true);
      setState(() {
        _isUploading = false;
        _isFileSelected = true;
        _progress = 0;
      });
    }
  }

  void _cancelSelection() {
    setState(() {
      _fileName = null;
      _fileBytes = null;
      _isFileSelected = false;
      _progress = 0;
      _isUploading = false;
      _isDone = false;
    });
    widget.onErrorChanged?.call(false);
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
      _fileBytes = null;
      _isFileSelected = false;
      _progress = 0;
      _isDone = false;
      _isAnalyzing = false;
    });
    widget.onErrorChanged?.call(false);
    widget.onAnalyze?.call();
  }

  void _handleAnalyze() {
    if (_isAnalyzing || !_isDone) return;
    setState(() => _isAnalyzing = true);
    _doReset();
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent;
    if (_fileName == null) {
      cardContent = _buildIdle(context);
    } else if (_isFileSelected && !_isUploading) {
      cardContent = _buildFileSelected(context);
    } else if (_isDone) {
      cardContent = _buildDone(context);
    } else {
      cardContent = _buildUploading(context);
    }

    final card = GestureDetector(
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
            child: cardContent,
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

  Widget _buildFileSelected(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _cancelSelection,
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),
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
          top: 140,
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
          bottom: 24,
          left: 15,
          right: 15,
          child: SizedBox(
            width: 260,
            height: 36,
            child: ElevatedButton.icon(
              onPressed: _handleUpload,
              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
              label: const Text(
                'Upload',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple200,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
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
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _progress),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOutCubic,
      builder: (context, animatedValue, _) {
        final percent = (animatedValue * 100).toInt();
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
                // Quando _progress == 0 a barra é indeterminada: esconde %
                _progress == 0 ? '' : '$percent%',
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
              child: LinearProgressIndicator(
                // null = indeterminado enquanto _progress == 0 (antes do
                // primeiro evento onSendProgress chegar ou uploads rápidos).
                value: _progress == 0 ? null : animatedValue,
                backgroundColor: AppColors.blue300.withValues(alpha: 0.3),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.blue300),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        );
      },
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
          child: LinearProgressIndicator(
            value: 1.0,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green400),
            borderRadius: BorderRadius.circular(3),
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
