import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:flutter_cookiecutter/core/theme/app_colors.dart';
import 'package:flutter_cookiecutter/core/network/api_client_provider.dart';
import 'package:flutter_cookiecutter/features/analysis/domain/entities/peca.dart';

class PecaViewerScreen extends ConsumerStatefulWidget {
  final Peca peca;
  final int processoId;

  const PecaViewerScreen({
    super.key,
    required this.peca,
    required this.processoId,
  });

  @override
  ConsumerState<PecaViewerScreen> createState() => _PecaViewerScreenState();
}

@visibleForTesting
String buildProcessPdfUrl(String apiUrl, int processoId) =>
    '$apiUrl/processo/$processoId/pdf';

class _PecaViewerScreenState extends ConsumerState<PecaViewerScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  bool _documentLoaded = false;
  bool _isLoading = true;
  String? _errorMessage;
  String? _pdfUrl;
  Uint8List? _pdfBytes;
  Key _viewerKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    final apiUrl = dotenv.env['API_URL']?.trim();

    debugPrint(
      'PecaViewer: init processoId=${widget.processoId}, paginaInicial=${widget.peca.paginaInicial}',
    );

    if (apiUrl == null || apiUrl.isEmpty) {
      _errorMessage = 'A variavel API_URL nao foi configurada.';
      debugPrint('PecaViewer: $_errorMessage');
      _isLoading = false;
      return;
    }

    // O backend expõe o PDF do processo em GET /processo/:id/pdf
    _pdfUrl = buildProcessPdfUrl(apiUrl, widget.processoId);
    debugPrint('PecaViewer: pdfUrl=$_pdfUrl');
    unawaited(_loadPdfBytes(_pdfUrl!));
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _loadPdfBytes(String pdfUrl) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.get<List<int>>(
        pdfUrl,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (_) => true,
        ),
      );

      final contentType = response.headers.value('content-type') ?? 'unknown';
      final statusCode = response.statusCode ?? 0;
      final body = response.data;

      if (statusCode != 200) {
        final bodyPreview = body == null
            ? ''
            : String.fromCharCodes(body.take(180).toList());
        debugPrint(
          'PecaViewer: pdf status=$statusCode contentType=$contentType bodyPreview=$bodyPreview',
        );
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'A resposta da API foi $statusCode.';
        });
        return;
      }

      if (body == null || body.isEmpty) {
        debugPrint(
          'PecaViewer: pdf vazio contentType=$contentType status=$statusCode',
        );
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'O PDF veio vazio da API.';
        });
        return;
      }

      debugPrint(
        'PecaViewer: pdf status=$statusCode contentType=$contentType bytes=${body.length}',
      );

      if (!mounted) return;
      setState(() {
        _pdfBytes = Uint8List.fromList(body);
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('PecaViewer: load error url=$pdfUrl error=$e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Nao foi possivel carregar o PDF.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peca.nome),
        backgroundColor: AppColors.purple700,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // PDF Viewer
          if (_pdfBytes != null)
            SfPdfViewer.memory(
              _pdfBytes!,
              key: _viewerKey,
              controller: _pdfController,
              onDocumentLoaded: (_) {
                if (!_documentLoaded) {
                  _documentLoaded = true;
                  final page = widget.peca.paginaInicial > 0
                      ? widget.peca.paginaInicial
                      : 1;
                  _pdfController.jumpToPage(page);
                }
                setState(() => _isLoading = false);
              },
              onDocumentLoadFailed: (details) {
                debugPrint(
                  'PecaViewer: falha ao carregar PDF url=$_pdfUrl descricao=${details.description}',
                );
                setState(() {
                  _isLoading = false;
                  _errorMessage = details.description;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Erro ao carregar PDF: ${details.description}',
                    ),
                    backgroundColor: AppColors.red300,
                  ),
                );
              },
            ),

          // Loading indicator
          if (_isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.purple800),
                  const SizedBox(height: 16),
                  const Text(
                    'Carregando documento...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

          // Erro amigável
          if (_errorMessage != null && !_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppColors.red300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Não foi possível abrir o documento',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                          _documentLoaded = false;
                          _pdfBytes = null;
                          // força recarregar o viewer
                          _viewerKey = UniqueKey();
                        });
                        if (_pdfUrl != null) {
                          unawaited(_loadPdfBytes(_pdfUrl!));
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
