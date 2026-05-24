import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cookiecutter/features/history/domain/entities/history.dart';
import 'package:flutter_cookiecutter/features/history/domain/repositories/history_repository.dart';
import 'package:flutter_cookiecutter/features/history/domain/use_cases/history_use_cases.dart';
import 'package:flutter_cookiecutter/features/history/presentation/petition_history/providers/history_provider.dart';
import 'package:flutter_cookiecutter/features/history/presentation/petition_history/screens/petition_history_screen.dart';
import 'package:flutter_cookiecutter/features/history/presentation/petition_history/view_models/history_state.dart';
import 'package:flutter_cookiecutter/features/history/presentation/petition_history/view_models/history_view_model.dart';

void main() {
  late FakeHistoryViewModel fakeViewModel;

  setUp(() {
    fakeViewModel = FakeHistoryViewModel();
  });

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        historyViewModelProvider.overrideWith((ref) => fakeViewModel),
      ],
      child: const MaterialApp(home: Scaffold(body: PetitionHistoryScreen())),
    );
  }

  group('PetitionHistoryScreen', () {
    testWidgets('deve mostrar titulo da tela', (tester) async {
      await tester.pumpWidget(createWidget());
      expect(find.text('Histórico de Análises'), findsOneWidget);
    });

    testWidgets('deve mostrar estado vazio quando nao houver itens', (
      tester,
    ) async {
      fakeViewModel.state = const HistoryState(isLoading: false, items: []);
      await tester.pumpWidget(createWidget());
      expect(find.text('Nenhuma análise realizada ainda.'), findsOneWidget);
    });

    testWidgets('deve renderizar cards do historico', (tester) async {
      final history = AnalysisHistory(
        petitionId: 10,
        fileName: 'Ação Popular.pdf',
        resumo: 'Resumo teste',
        suggestions: const [],
        analyzedAt: DateTime.now(),
      );

      fakeViewModel.state = HistoryState(isLoading: false, items: [history]);
      await tester.pumpWidget(createWidget());
      expect(find.text('Ação Popular.pdf'), findsOneWidget);
    });

    testWidgets('deve filtrar busca ao digitar', (tester) async {
      await tester.pumpWidget(createWidget());
      final field = find.byType(TextField);
      await tester.enterText(field, 'ação');
      expect(fakeViewModel.lastSearch, 'ação');
    });

    testWidgets('deve mostrar loading', (tester) async {
      fakeViewModel.state = const HistoryState(isLoading: true, items: []);
      await tester.pumpWidget(createWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve agrupar itens por Hoje', (tester) async {
      final history = AnalysisHistory(
        petitionId: 10,
        fileName: 'Mandado de Segurança.pdf',
        resumo: 'Resumo teste',
        suggestions: const [],
        analyzedAt: DateTime.now(),
      );

      fakeViewModel.state = HistoryState(isLoading: false, items: [history]);
      await tester.pumpWidget(createWidget());
      expect(find.text('Hoje'), findsOneWidget);
    });
  });
}

class FakeHistoryViewModel extends HistoryViewModel {
  FakeHistoryViewModel() : super(FakeGetAllHistoryUseCase());

  String? lastSearch;

  @override
  void updateSearch(String value) {
    lastSearch = value;
    super.updateSearch(value);
  }
}

class FakeGetAllHistoryUseCase extends GetAllHistoryUseCase {
  FakeGetAllHistoryUseCase() : super(FakeHistoryRepository());

  @override
  Future<List<AnalysisHistory>> execute() async => [];
}

class FakeHistoryRepository implements HistoryRepository {
  @override
  Future<List<AnalysisHistory>> getAll() async => [];
}