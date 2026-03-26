import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cookiecutter/features/petition/presentation/petition_upload/widgets/petition_upload_card.dart';

void main() {
  Widget buildTestWidget({Future<String?> Function()? onPickFile}) {
    return MaterialApp(
      home: Scaffold(
        body: PetitionUploadCard(onPickFile: onPickFile),
      ),
    );
  }

  group('PetitionUploadCard — estado inicial (idle)', () {
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

  group('PetitionUploadCard — estado de upload (uploading)', () {
    testWidgets('exibe ícone de arquivo após selecionar um arquivo',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onPickFile: () async => 'peticao.pdf'),
      );

      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump(); // dispatch tap
      await tester.pump(); // resolve future + setState

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

    testWidgets('exibe texto "Fazendo upload..."', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onPickFile: () async => 'peticao.pdf'),
      );

      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(find.text('Fazendo upload...'), findsOneWidget);
    });

    testWidgets('não abre seletor novamente enquanto upload está em andamento',
        (tester) async {
      var callCount = 0;
      await tester.pumpWidget(
        buildTestWidget(
          onPickFile: () async {
            callCount++;
            return 'peticao.pdf';
          },
        ),
      );

      // Primeiro toque: inicia upload
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      // Segundo toque durante upload: deve ser ignorado (onTap == null)
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      expect(callCount, 1);
    });
  });

  group('PetitionUploadCard — estado concluído (done)', () {
    Future<void> startAndCompleteUpload(WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(onPickFile: () async => 'peticao.pdf'),
      );
      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();
      // 100 ticks × 80 ms = 8 000 ms para progress chegar a 1.0
      await tester.pump(const Duration(milliseconds: 8100));
    }

    testWidgets('exibe texto "Concluído" ao finalizar', (tester) async {
      await startAndCompleteUpload(tester);

      expect(find.text('Concluído'), findsOneWidget);

      // drena o Future.delayed(2s) pendente para não deixar timers abertos
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
    });

    testWidgets('exibe "100%" ao finalizar', (tester) async {
      await startAndCompleteUpload(tester);

      expect(find.text('100%'), findsOneWidget);

      // drena o Future.delayed(2s) pendente para não deixar timers abertos
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
    });

    testWidgets('retorna para idle 2 segundos após conclusão', (tester) async {
      await startAndCompleteUpload(tester);

      // aguarda o reset automático de 2 s
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(find.text('Clique para fazer upload'), findsOneWidget);
      expect(find.text('PDF, DOCX ou TXT'), findsOneWidget);
    });
  });

  group('PetitionUploadCard — cancelamento', () {
    testWidgets('permanece em idle quando seletor é cancelado', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onPickFile: () async => null), // usuário cancelou
      );

      await tester.tap(find.byType(PetitionUploadCard));
      await tester.pump();
      await tester.pump();

      // Deve permanecer no estado idle
      expect(find.text('Clique para fazer upload'), findsOneWidget);
    });
  });
}
