import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('basic widget test', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('Hello CI')));

    expect(find.text('Hello CI'), findsOneWidget);
  });
}
