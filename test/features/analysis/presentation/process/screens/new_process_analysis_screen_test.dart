import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cookiecutter/core/theme/app_theme.dart';
import 'package:flutter_cookiecutter/features/analysis/domain/entities/especie_precedente.dart';
import 'package:flutter_cookiecutter/features/analysis/domain/entities/processo_juridico.dart';
import 'package:flutter_cookiecutter/features/analysis/domain/entities/tribunal_precedente.dart';
import 'package:flutter_cookiecutter/features/analysis/domain/repositories/filters_repository.dart';
import 'package:flutter_cookiecutter/features/analysis/domain/repositories/process_repository.dart';
import 'package:flutter_cookiecutter/features/analysis/domain/use_cases/filters_use_case.dart';
import 'package:flutter_cookiecutter/features/analysis/domain/use_cases/process_use_case.dart';
import 'package:flutter_cookiecutter/features/analysis/presentation/process/providers/new_process_analysis_providers.dart';
import 'package:flutter_cookiecutter/features/analysis/presentation/process/screens/new_process_analysis_screen.dart';
import 'package:flutter_cookiecutter/routes/app_router.dart';

class FakeFiltersRepository implements FiltersRepository {
  FakeFiltersRepository(this.tribunais);

  final List<TribunalPrecedente> tribunais;

  @override
  Future<List<TribunalPrecedente>> fetchTribunais() async => tribunais;

  @override
  Future<List<EspeciePrecedente>> fetchEspecies() async => const [];
}

class FakeProcessRepository implements ProcessRepository {
  FakeProcessRepository({required this.shouldFail});

  final bool shouldFail;

  @override
  Future<ProcessoJuridico> createProcessoJuridico({
    required File file,
    required int instancia,
    required String classeProcessual,
    required String areaDireito,
    required int tribunalPrecedenteId,
  }) async {
    if (shouldFail) {
      throw Exception('request failed');
    }

    return ProcessoJuridico(
      caminhoArquivo: file.path,
      instancia: instancia,
      classeProcessual: classeProcessual,
      areaDireito: areaDireito,
      tribunalPrecedenteId: tribunalPrecedenteId,
    );
  }
}

Future<ProviderContainer> pumpScreen(
  WidgetTester tester, {
  required bool shouldFail,
  bool submit = true,
}) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;

  final container = ProviderContainer(
    overrides: [
      processFiltersUseCaseProvider.overrideWithValue(
        FiltersUseCase(
          FakeFiltersRepository([
            TribunalPrecedente(id: 1, nome: 'Tribunal de Justiça', sigla: 'TJ'),
          ]),
        ),
      ),
      processUseCaseProvider.overrideWithValue(
        ProcessUseCase(
          repository: FakeProcessRepository(shouldFail: shouldFail),
        ),
      ),
    ],
  );

  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        onGenerateRoute: (settings) {
          if (settings.name == AppRouter.processAnalysis) {
            return MaterialPageRoute<void>(
              builder: (_) => const Scaffold(
                body: Text('process-analysis-screen'),
              ),
            );
          }

          return MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: NewProcessAnalysisScreen()),
          );
        },
      ),
    ),
  );

  await tester.pumpAndSettle();

  final notifier = container.read(newProcessAnalysisViewModelProvider.notifier);
  notifier.setAreaDireito('Direito Civil');
  notifier.setClasseProcessual('Ação de família');
  notifier.setInstancia(1);
  notifier.setTribunal(
    TribunalPrecedente(id: 1, nome: 'Tribunal de Justiça', sigla: 'TJ'),
  );
  notifier.setFile(File('documento.pdf'));

  if (!submit) {
    return container;
  }

  await tester.tap(find.text('Analisar documento'));
  await tester.pump();
  await tester.pumpAndSettle();

  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('exibe a tela e as ações principais', (tester) async {
    await pumpScreen(
      tester,
      shouldFail: false,
      submit: false,
    );

    expect(find.text('Nova Análise de Processo'), findsOneWidget);
    expect(find.text('Arquivo'), findsOneWidget);
    expect(find.text('Contexto do Tribunal'), findsOneWidget);
    expect(find.text('Tribunal'), findsWidgets);
    expect(find.text('Instância'), findsWidgets);
    expect(find.text('Analisar documento'), findsOneWidget);
    expect(find.text('Refinar Análise'), findsOneWidget);
  });

  testWidgets('atualiza o estado quando o processo é criado', (
    tester,
  ) async {
    final container = await pumpScreen(
      tester,
      shouldFail: false,
    );

    final state = container.read(newProcessAnalysisViewModelProvider);
    expect(state.createdProcesso, isNotNull);
    expect(state.errorMessage, isNull);
  });

  testWidgets('atualiza o estado quando a request falha', (
    tester,
  ) async {
    final container = await pumpScreen(
      tester,
      shouldFail: true,
    );

    final state = container.read(newProcessAnalysisViewModelProvider);
    expect(state.createdProcesso, isNull);
    expect(state.errorMessage, 'Nao foi possivel criar o processo juridico.');
  });
}