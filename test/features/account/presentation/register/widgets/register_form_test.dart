import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_cookiecutter/core/errors/api_exception.dart';
import 'package:flutter_cookiecutter/core/theme/app_theme.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/register_usecase.dart';
import 'package:flutter_cookiecutter/features/account/presentation/register/providers/register_usecase_provider.dart';
import 'package:flutter_cookiecutter/features/account/presentation/register/view_models/register_view_model.dart';
import 'package:flutter_cookiecutter/features/account/presentation/register/widgets/register_form.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;

  Future<void> pumpRegisterForm(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          registerViewModelProvider.overrideWith(
            (ref) => RegisterViewModel(mockRegisterUsecase, ref),
          ),
          accessLevelsProvider.overrideWith((ref) => Future.value([
            {'id': '1', 'nome': 'advogado'},
            {'id': '2', 'nome': 'juiz'},
            {'id': '3', 'nome': 'user'},
          ])),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: Padding(padding: EdgeInsets.all(16), child: RegisterForm()),
          ),
        ),
      ),
    );
  }

  Future<void> fillValidForm(WidgetTester tester) async {
    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), 'John Doe');
    await tester.enterText(fields.at(1), 'john@doe.com');
    
    // Selecionar cargo
    await tester.tap(find.text('Selecione seu cargo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advogado').last);
    await tester.pumpAndSettle();

    await tester.enterText(fields.at(2), 'Senha@123');
  }

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();

    when(
      () => mockRegisterUsecase.execute(any(), any(), any(), any()),
    ).thenAnswer((_) async {});
  });

  group('RegisterForm widget', () {
    testWidgets('renders title, fields and submit button', (
      WidgetTester tester,
    ) async {
      await pumpRegisterForm(tester);
      await tester.pumpAndSettle();

      expect(find.text('CRIE SUA CONTA'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Cargo'), findsOneWidget);
      expect(find.text('Cadastrar'), findsOneWidget);
    });

    testWidgets('shows generic form error when fields are invalid', (
      WidgetTester tester,
    ) async {
      await pumpRegisterForm(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Por favor, preencha todos os campos corretamente.'),
        findsOneWidget,
      );
    });

    testWidgets('shows error when cargo is not selected', (
      WidgetTester tester,
    ) async {
      await pumpRegisterForm(tester);
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@doe.com');
      await tester.enterText(fields.at(2), 'Senha@123');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, selecione um cargo.'), findsOneWidget);
    });

    testWidgets('submits and trims name when form is valid', (
      WidgetTester tester,
    ) async {
      await pumpRegisterForm(tester);
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '  John Doe  ');
      await tester.enterText(fields.at(1), 'john@doe.com');
      
      // Selecionar cargo
      await tester.tap(find.text('Selecione seu cargo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Advogado').last);
      await tester.pumpAndSettle();

      await tester.enterText(fields.at(2), 'Senha@123');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      verify(
        () => mockRegisterUsecase.execute(
          'John Doe',
          'john@doe.com',
          'Senha@123',
          'advogado',
        ),
      ).called(1);
    });

    testWidgets('shows api error message from register state', (
      WidgetTester tester,
    ) async {
      when(
        () => mockRegisterUsecase.execute(any(), any(), any(), any()),
      ).thenThrow(const ApiException(message: 'Email already in use'));

      await pumpRegisterForm(tester);
      await tester.pumpAndSettle();
      await fillValidForm(tester);

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('Email already in use'), findsOneWidget);
    });

    testWidgets('shows loading label and disables inputs while submitting', (
      WidgetTester tester,
    ) async {
      final completer = Completer<void>();
      when(
        () => mockRegisterUsecase.execute(any(), any(), any(), any()),
      ).thenAnswer((_) => completer.future);

      await pumpRegisterForm(tester);
      await fillValidForm(tester);

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('Cadastrando...'), findsOneWidget);

      final fields = tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      );
      expect(fields.every((field) => field.enabled == false), isTrue);

      completer.complete();
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar'), findsOneWidget);
    });

    testWidgets('toggles password visibility icon', (
      WidgetTester tester,
    ) async {
      await pumpRegisterForm(tester);

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}
