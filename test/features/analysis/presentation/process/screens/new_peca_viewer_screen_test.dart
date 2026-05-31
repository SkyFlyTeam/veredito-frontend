import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cookiecutter/features/analysis/presentation/process/screens/new_peca_viewer_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('monta a rota correta do PDF do processo', () {
    expect(
      buildProcessPdfUrl('http://localhost:3000', 10),
      'http://localhost:3000/processo/10/pdf',
    );
  });
}
