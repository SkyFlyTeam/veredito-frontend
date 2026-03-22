import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cookiecutter/core/theme/app_colors.dart';
import 'package:flutter_cookiecutter/shared/widgets/app_input.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('renderiza label e hint no estado padrao', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const AppInput(labelText: 'Nome completo', hintText: 'Joe Doe'),
      ),
    );

    expect(find.text('Nome completo'), findsOneWidget);
    expect(find.text('Joe Doe'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('estado de erro mostra mensagem e borda vermelha', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        const AppInput.error(
          labelText: 'Nome completo',
          hintText: 'Joe Doe',
          errorMessage: 'Nome incorreto.',
        ),
      ),
    );

    expect(find.text('Nome incorreto.'), findsOneWidget);

    final inputDecorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    final enabledBorder =
        inputDecorator.decoration.enabledBorder! as OutlineInputBorder;

    expect(enabledBorder.borderSide.color, AppColors.red300);
  });

  testWidgets('input de senha alterna obscureText ao tocar no icone', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildTestApp(
        const AppInput.password(
          labelText: 'Senha',
          hintText: 'Digite sua senha',
        ),
      ),
    );

    EditableText editable = tester.widget<EditableText>(
      find.byType(EditableText),
    );
    expect(editable.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.obscureText, isFalse);
  });
}
