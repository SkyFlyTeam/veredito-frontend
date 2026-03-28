import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cookiecutter/features/petition/presentation/petition_upload/widgets/petition_upload_card.dart';

void main() {
  Widget buildTestWidget({
    Future<String?> Function()? onPickFile,
    void Function(bool)? onErrorChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PetitionUploadCard(
          onPickFile: onPickFile,
          onErrorChanged: onErrorChanged,
        ),
      ),
    );
  }

  // Helper: seleciona arquivo válido e aguarda upload concluir (100 ticks × 80 ms)
  Future<void> completeUpload(WidgetTester tester,
      {void Function(bool)? onErrorChanged}) async {
    await tester.pumpWidget(
      buildTestWidget(
        onPickFile: () async => 'peticao.pdf',
        onErrorChanged: onErrorChanged,
      ),
    );
    await tester.tap(find.byType(PetitionUploadCard));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 8100));
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

  // ─── Durante o upload ────────────────────────────────────────────────────────
  group('durante o upload (uploading)', () {
    testWidgets('exibe ícone de arquivo após selecionar', (tester) async {
      await tester.pumpWidget(
          buildTestWidget(onPickFile: () async => 'peticao.pdf'));
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.insert_drive_file_outlined), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
    });

    testWidgets('exibe o nome do arquivo selecionado', (tester) async {
      await tester.pumpWidget(
          buildTestWidget(onPickFile: () async => 'peticao.pdf'));
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(find.text('peticao.pdf'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
    });

    testWidgets('exibe "Fazendo upload..."', (tester) async {
      await tester.pumpWidget(
          buildTestWidget(onPickFile: () async => 'peticao.pdf'));
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(find.text('Fazendo upload...'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
    });

    testWidgets('não abre seletor novamente durante o upload', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(buildTestWidget(
        onPickFile: () async {
          callCount++;
          return 'peticao.pdf';
        },
      ));
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();
      // Segundo toque durante upload deve ser ignorado
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(callCount, 1);

      await tester.pump(const Duration(seconds: 5));
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

    testWidgets('retorna para idle automaticamente após 5 s', (tester) async {
      await completeUpload(tester);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();

      expect(find.text('Clique para fazer upload'), findsOneWidget);
      expect(find.text('PDF, DOCX ou TXT'), findsOneWidget);
    });
  });

  // ─── Cancelamento ────────────────────────────────────────────────────────────
  group('cancelamento do seletor', () {
    testWidgets('permanece em idle quando seletor é cancelado', (tester) async {
      await tester.pumpWidget(
          buildTestWidget(onPickFile: () async => null));
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(find.text('Clique para fazer upload'), findsOneWidget);
    });
  });

  // ─── Extensão inválida ───────────────────────────────────────────────────────
  group('extensão inválida', () {
    testWidgets('chama onErrorChanged(true) para extensão não permitida',
        (tester) async {
      bool? errorState;
      await tester.pumpWidget(buildTestWidget(
        onPickFile: () async => 'peticao.exe',
        onErrorChanged: (v) => errorState = v,
      ));
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(errorState, isTrue);
    });

    testWidgets('não inicia upload com extensão inválida', (tester) async {
      await tester.pumpWidget(
          buildTestWidget(onPickFile: () async => 'peticao.jpg'));
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.file_upload_outlined), findsOneWidget);
      expect(find.byIcon(Icons.insert_drive_file_outlined), findsNothing);
    });

    testWidgets('chama onErrorChanged(false) ao selecionar arquivo válido após erro',
        (tester) async {
      var callCount = 0;
      final files = ['peticao.exe', 'peticao.pdf'];
      final errorStates = <bool>[];

      await tester.pumpWidget(buildTestWidget(
        onPickFile: () async => files[callCount++],
        onErrorChanged: errorStates.add,
      ));

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
    });
  });
}
