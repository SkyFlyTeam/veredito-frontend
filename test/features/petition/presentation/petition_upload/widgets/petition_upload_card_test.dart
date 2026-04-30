import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cookiecutter/features/petition/presentation/petition_upload/widgets/petition_upload_card.dart';

void main() {
  Widget buildTestWidget({
    Future<String?> Function()? onPickFile,
    void Function(bool)? onErrorChanged,
    Future<void> Function(String, List<int>, void Function(double))?
    onUploadFile,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PetitionUploadCard(
          onPickFile: onPickFile,
          onErrorChanged: onErrorChanged,
          onUploadFile: onUploadFile,
        ),
      ),
    );
  }

  // Helper: seleciona arquivo válido e conclui upload tocando o botão "Upload"
  Future<void> completeUpload(
    WidgetTester tester, {
    void Function(bool)? onErrorChanged,
  }) async {
    await tester.pumpWidget(
      buildTestWidget(
        onPickFile: () async => 'peticao.pdf',
        onErrorChanged: onErrorChanged,
      ),
    );
    // Passo 1: toca o card → arquivo selecionado
    await tester.tap(find.byType(PetitionUploadCard));
    await tester.pump();
    await tester.pump();
    // Passo 2: toca "Upload" → onUploadFile é nulo → resolve imediatamente
    // mas minDisplay (800ms) + animação de preenchimento (350ms) precisam expirar.
    await tester.tap(find.text('Upload'));
    await tester.pump();
    await tester.pump(
      const Duration(milliseconds: 800),
    ); // minDisplay → _progress=1.0
    await tester.pump(
      const Duration(milliseconds: 350),
    ); // animação → _isDone=true
    await tester.pump();
  }

  // ─── Estado inicial ──────────────────────────────────────────────────────────
  group('estado inicial (idle)', () {
    testWidgets('exibe ícone de upload', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byIcon(Icons.file_upload_outlined), findsOneWidget);
    });

    testWidgets('exibe texto "Clique para fazer upload"', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Clique para fazer upload'), findsOneWidget);
    });

    testWidgets('exibe formatos aceitos "PDF, DOCX ou TXT"', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('PDF, DOCX ou TXT'), findsOneWidget);
    });
  });

  // ─── Estado: arquivo selecionado ─────────────────────────────────────────────
  group('estado: arquivo selecionado', () {
    testWidgets('exibe ícone de documento após selecionar arquivo', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(onPickFile: () async => 'peticao.pdf'),
      );
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.insert_drive_file_outlined), findsOneWidget);
    });

    testWidgets('exibe o nome do arquivo selecionado', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onPickFile: () async => 'peticao.pdf'),
      );
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(find.text('peticao.pdf'), findsOneWidget);
    });

    testWidgets('exibe botão "Upload"', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onPickFile: () async => 'peticao.pdf'),
      );
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(find.text('Upload'), findsOneWidget);
    });

    testWidgets('ao tocar X, retorna ao estado idle', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onPickFile: () async => 'peticao.pdf'),
      );
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.text('Clique para fazer upload'), findsOneWidget);
      expect(find.text('PDF, DOCX ou TXT'), findsOneWidget);
    });

    testWidgets('ao tocar X, limpa o nome do arquivo', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onPickFile: () async => 'peticao.pdf'),
      );
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.text('peticao.pdf'), findsNothing);
    });
  });

  // ─── Durante o upload ────────────────────────────────────────────────────────
  group('durante o upload (uploading)', () {
    testWidgets('exibe ícone de arquivo durante o upload', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        buildTestWidget(
          onPickFile: () async => 'peticao.pdf',
          onUploadFile: (_, __, ___) => completer.future,
        ),
      );
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Upload'));
      await tester.pump();

      expect(find.byIcon(Icons.insert_drive_file_outlined), findsOneWidget);

      completer.complete();
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 800),
      ); // minDisplay → _progress=1.0
      await tester.pump(
        const Duration(milliseconds: 350),
      ); // animação → _isDone=true
      await tester.pump(const Duration(seconds: 5)); // auto-reset → idle
      await tester.pump();
    });

    testWidgets('exibe o nome do arquivo durante o upload', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        buildTestWidget(
          onPickFile: () async => 'peticao.pdf',
          onUploadFile: (_, __, ___) => completer.future,
        ),
      );
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Upload'));
      await tester.pump();

      expect(find.text('peticao.pdf'), findsOneWidget);

      completer.complete();
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 800),
      ); // minDisplay → _progress=1.0
      await tester.pump(
        const Duration(milliseconds: 350),
      ); // animação → _isDone=true
      await tester.pump(const Duration(seconds: 5)); // auto-reset → idle
      await tester.pump();
    });

    testWidgets('exibe "Fazendo upload..."', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        buildTestWidget(
          onPickFile: () async => 'peticao.pdf',
          onUploadFile: (_, __, ___) => completer.future,
        ),
      );
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Upload'));
      await tester.pump();

      expect(find.text('Fazendo upload...'), findsOneWidget);

      completer.complete();
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 800),
      ); // minDisplay → _progress=1.0
      await tester.pump(
        const Duration(milliseconds: 350),
      ); // animação → _isDone=true
      await tester.pump(const Duration(seconds: 5)); // auto-reset → idle
      await tester.pump();
    });

    testWidgets('não abre seletor novamente durante o upload', (tester) async {
      var callCount = 0;
      final completer = Completer<void>();
      await tester.pumpWidget(
        buildTestWidget(
          onPickFile: () async {
            callCount++;
            return 'peticao.pdf';
          },
          onUploadFile: (_, __, ___) => completer.future,
        ),
      );
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Upload'));
      await tester.pump();
      // Segundo toque durante upload deve ser ignorado
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();

      expect(callCount, 1);

      completer.complete();
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 800),
      ); // minDisplay → _progress=1.0
      await tester.pump(
        const Duration(milliseconds: 350),
      ); // animação → _isDone=true
      await tester.pump(const Duration(seconds: 5)); // auto-reset → idle
      await tester.pump();
    });
  });

  // ─── Upload concluído ────────────────────────────────────────────────────────
  group('upload concluído (done)', () {
    testWidgets('exibe "Concluído" ao finalizar', (tester) async {
      await completeUpload(tester);
      expect(find.text('Concluído'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
    });

    testWidgets('exibe "100%" ao finalizar', (tester) async {
      await completeUpload(tester);
      expect(find.text('100%'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
    });
  });

  // ─── Cancelamento ────────────────────────────────────────────────────────────
  group('cancelamento do seletor', () {
    testWidgets('permanece em idle quando seletor é cancelado', (tester) async {
      await tester.pumpWidget(buildTestWidget(onPickFile: () async => null));
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(find.text('Clique para fazer upload'), findsOneWidget);
    });
  });

  // ─── Extensão inválida ───────────────────────────────────────────────────────
  group('extensão inválida', () {
    testWidgets('chama onErrorChanged(true) para extensão não permitida', (
      tester,
    ) async {
      bool? errorState;
      await tester.pumpWidget(
        buildTestWidget(
          onPickFile: () async => 'peticao.exe',
          onErrorChanged: (v) => errorState = v,
        ),
      );
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(errorState, isTrue);
    });

    testWidgets('não inicia upload com extensão inválida', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onPickFile: () async => 'peticao.jpg'),
      );
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.file_upload_outlined), findsOneWidget);
      expect(find.byIcon(Icons.insert_drive_file_outlined), findsNothing);
    });

    testWidgets(
      'chama onErrorChanged(false) ao selecionar arquivo válido após erro',
      (tester) async {
        var callCount = 0;
        final files = ['peticao.exe', 'peticao.pdf'];
        final errorStates = <bool>[];

        await tester.pumpWidget(
          buildTestWidget(
            onPickFile: () async => files[callCount++],
            onErrorChanged: errorStates.add,
          ),
        );

        // 1ª seleção: inválida → true
        await tester.tap(find.byType(PetitionUploadCard));
        await tester.pump();
        await tester.pump();

        // 2ª seleção: válida → false
        await tester.tap(find.byType(PetitionUploadCard));
        await tester.pump();
        await tester.pump();

        expect(errorStates, containsAllInOrder([true, false]));

        await tester.pump(const Duration(seconds: 5));
        await tester.pump();
      },
    );
  });
}
