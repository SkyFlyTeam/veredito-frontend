import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cookiecutter/core/theme/app_theme.dart';
import 'package:flutter_cookiecutter/features/analysis/presentation/petition/screens/new_petition_analysis_screen.dart';
import 'package:flutter_cookiecutter/features/petition/data/models/peticao_document.dart';
import 'package:flutter_cookiecutter/features/petition/domain/entities/peticao.dart';
import 'package:flutter_cookiecutter/features/petition/domain/repositories/petition_repository.dart';
import 'package:flutter_cookiecutter/features/petition/domain/use_cases/upload_petition_usecase.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/petition_upload/providers/petition_upload_provider.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/petition_upload/view_models/petition_upload_view_model.dart';
import 'package:flutter_cookiecutter/features/analysis/presentation/shared/widgets/petition_upload_card.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/shared/providers/petition_documents_provider.dart';
import 'package:flutter_cookiecutter/routes/app_router.dart';

class FakePetitionRepository implements PetitionRepository {
  FakePetitionRepository({required this.petitionToReturn});

  final Peticao petitionToReturn;
  String? uploadedFileName;
  List<int>? uploadedBytes;

  @override
  Future<Peticao> uploadPetition(
    String fileName,
    List<int> bytes, {
    void Function(double)? onProgress,
  }) async {
    uploadedFileName = fileName;
    uploadedBytes = bytes;
    onProgress?.call(0.5);
    onProgress?.call(1.0);
    return petitionToReturn;
  }
}

Future<ProviderContainer> pumpScreen(
  WidgetTester tester, {
  required FakePetitionRepository repository,
  required ValueChanged<Object?> onPrecedentRoute,
}) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;

  final container = ProviderContainer(
    overrides: [
      petitionUploadProvider.overrideWith(
        (ref) => PetitionUploadViewModel(UploadPetitionUsecase(repository)),
      ),
    ],
  );

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    container.dispose();
  });

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        onGenerateRoute: (settings) {
          if (settings.name == AppRouter.precedentAnalysis) {
            onPrecedentRoute(settings.arguments);
            return MaterialPageRoute<void>(
              builder: (_) => const Scaffold(
                body: Text('precedent-analysis-screen'),
              ),
            );
          }

          return MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: NewPetitionAnalysisScreen()),
          );
        },
      ),
    ),
  );

  await tester.pumpAndSettle();

  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('exibe a nova tela com as ações principais', (tester) async {
    final repository = FakePetitionRepository(
      petitionToReturn: Peticao(
        id: 1,
        caminhoArquivo: 'uploads/peticao.pdf',
        resumo: 'Resumo',
        createdAt: DateTime(2026, 5, 26),
        usuarioId: 10,
      ),
    );

    await pumpScreen(
      tester,
      repository: repository,
      onPrecedentRoute: (_) {},
    );

    expect(find.text('Nova Análise de Petição'), findsOneWidget);
    expect(find.text('Arquivo'), findsOneWidget);
    expect(find.text('Analisar documento'), findsOneWidget);
    expect(find.text('Refinar Análise'), findsOneWidget);

    final analyzeButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Analisar documento'),
    );
    expect(analyzeButton.onPressed, isNull);
  });

  testWidgets('faz upload pela provider e navega com a peticao retornada', (
    tester,
  ) async {
    final petition = Peticao(
      id: 42,
      caminhoArquivo: 'uploads/peticao.pdf',
      resumo: 'Resumo',
      createdAt: DateTime(2026, 5, 26),
      usuarioId: 7,
    );
    final repository = FakePetitionRepository(petitionToReturn: petition);
    Object? pushedArgument;

    final container = await pumpScreen(
      tester,
      repository: repository,
      onPrecedentRoute: (argument) => pushedArgument = argument,
    );

    final uploadCard = tester.widget<PetitionUploadCard>(
      find.byType(PetitionUploadCard),
    );

    await uploadCard.onUploadFile!(
      'peticao.pdf',
      const [1, 2, 3],
      (_) {},
    );
    await tester.pumpAndSettle();

    expect(repository.uploadedFileName, 'peticao.pdf');
    expect(repository.uploadedBytes, const [1, 2, 3]);
    expect(container.read(petitionUploadProvider).petition, same(petition));

    final document = PeticaoDocument(
      id: 'doc-1',
      fileName: 'peticao.pdf',
      extension: 'pdf',
      uploadedAt: DateTime(2026, 5, 26),
    );
    uploadCard.onUploadComplete!(document);

    expect(container.read(petitionDocumentsProvider), [document]);

    await tester.tap(find.text('Analisar documento'));
    await tester.pumpAndSettle();

    expect(pushedArgument, same(petition));
    expect(find.text('precedent-analysis-screen'), findsOneWidget);
  });
}