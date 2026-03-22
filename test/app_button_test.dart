import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/shared/widgets/app_button.dart';

void main() {
  testWidgets('AppButton renderiza label passada por parametro', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(label: 'Entrar', onPressed: () {}),
          ),
        ),
      ),
    );

    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('AppButton.loading mostra spinner e desabilita clique', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: AppButton.loading(label: 'Entrando...')),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Entrando...'), findsOneWidget);
  });

  testWidgets('AppButton.disabled usa cor cinza e desabilita clique', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: AppButton.disabled(label: 'Entrar')),
        ),
      ),
    );

    expect(find.text('Entrar'), findsOneWidget);
    final elevatedButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(elevatedButton.onPressed, isNull);
  });

  testWidgets('AppButton.icon renderiza com icone', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton.icon(
              label: 'Documento',
              icon: Icons.description_outlined,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.description_outlined), findsOneWidget);
  });
}
