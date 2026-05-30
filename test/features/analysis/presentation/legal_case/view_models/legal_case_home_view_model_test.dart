import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_cookiecutter/features/analysis/data/models/legal_case_model.dart';
import 'package:flutter_cookiecutter/features/analysis/domain/entities/legal_case.dart';
import 'package:flutter_cookiecutter/features/analysis/domain/repositories/legal_case_repository.dart';
import 'package:flutter_cookiecutter/features/analysis/domain/use_cases/create_legal_case_use_case.dart';
import 'package:flutter_cookiecutter/features/analysis/presentation/legal_case/view_models/legal_case_home_view_model.dart';

class MockLegalCaseRepository extends Mock implements LegalCaseRepository {}

LegalCase _makeLegalCase({
  int id = 10,
  String areaDireito = 'Direito Civil',
  String pedidosPrincipais = 'Pedidos principais',
  String tesePretendida = 'Tese pretendida',
  String? fatosEstruturados = 'Fatos estruturados',
  String? fundamentosJuridicos = 'Fundamentos jurídicos',
  int? tribunalPrecedenteId = 7,
  String uf = 'SP',
  DateTime? createdAt,
  int usuarioId = 99,
}) {
  return LegalCase(
    id: id,
    areaDireito: areaDireito,
    pedidosPrincipais: pedidosPrincipais,
    tesePretendida: tesePretendida,
    uf: uf,
    fatosEstruturados: fatosEstruturados,
    fundamentosJuridicos: fundamentosJuridicos,
    tribunalPrecedenteId: tribunalPrecedenteId,
    createdAt: createdAt ?? DateTime.parse('2026-05-28T10:00:00.000Z'),
    usuarioId: usuarioId,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLegalCaseRepository repository;
  late CreateLegalCaseUsecase usecase;
  late LegalCaseHomeViewModel viewModel;

  setUp(() {
    repository = MockLegalCaseRepository();
    usecase = CreateLegalCaseUsecase(repository);
    viewModel = LegalCaseHomeViewModel(usecase);
  });

  group('LegalCaseHomeViewModel', () {
    test('mantem os novos campos no estado e envia no submit', () async {
      final createdCase = _makeLegalCase();
      final fileBytes = Uint8List.fromList([1, 2, 3]);
      final files = [
        PlatformFile(
          name: 'documento.pdf',
          size: fileBytes.length,
          bytes: fileBytes,
        ),
      ];

      when(
        () => repository.create(
          areaDireito: 'Direito Civil',
          pedidosPrincipais: 'Pedidos principais',
          tesePretendida: 'Tese pretendida',
          contextoFaticoFundamentos: 'Contexto fático e fundamentos',
          uf: 'SP',
          tribunalPrecedenteId: 7,
          files: [
            {
              'name': 'documento.pdf',
              'bytes': [1, 2, 3],
            },
          ],
        ),
      ).thenAnswer((_) async => createdCase);

      viewModel.setAreaDireito('Direito Civil');
      viewModel.setPedidosPrincipais('Pedidos principais');
      viewModel.setTesePretendida('Tese pretendida');
      viewModel.setContextoFaticoFundamentos('Contexto fático e fundamentos');
      viewModel.setUf('SP');
      viewModel.setTribunal(7);
      viewModel.setFiles(files);

      await viewModel.submit();

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.isSuccess, true);
      expect(viewModel.state.error, isNull);
      expect(viewModel.state.createdCase, same(createdCase));
      expect(viewModel.state.contextoFaticoFundamentos, isNotEmpty);

      verify(
        () => repository.create(
          areaDireito: 'Direito Civil',
          pedidosPrincipais: 'Pedidos principais',
          tesePretendida: 'Tese pretendida',
          contextoFaticoFundamentos: 'Contexto fático e fundamentos',
          uf: 'SP',
          tribunalPrecedenteId: 7,
          files: [
            {
              'name': 'documento.pdf',
              'bytes': [1, 2, 3],
            },
          ],
        ),
      ).called(1);
    });

    test('mantem a validacao apenas para os campos obrigatorios', () {
      viewModel.setContextoFaticoFundamentos('Texto auxiliar');

      expect(viewModel.state.contextoFaticoFundamentos, 'Texto auxiliar');
      expect(viewModel.state.isFormValid, false);

      viewModel.setAreaDireito('Direito Civil');
      viewModel.setPedidosPrincipais('Pedidos principais');
      viewModel.setTesePretendida('Tese pretendida');
      viewModel.setUf('SP');
      viewModel.setFiles([
        PlatformFile(
          name: 'documento.pdf',
          size: 3,
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
      ]);

      expect(viewModel.state.isFormValid, false);

      viewModel.setTribunal(7);

      expect(viewModel.state.isFormValid, true);
    });
  });

  group('LegalCaseModel', () {
    test('faz parse da resposta com snake_case e ids numericos em texto', () {
      final model = LegalCaseModel.fromJson({
        'id': '15',
        'area_direito': 'Direito Civil',
        'pedidos_principais': 'Pedidos principais',
        'tese_pretendida': 'Tese pretendida',
        'uf': 'SP',
        'fatos_estruturados': 'Fatos estruturados',
        'fundamentos_juridicos': 'Fundamentos jurídicos',
        'tribunal_precedente_id': '7',
        'created_at': '2026-05-28T10:00:00.000Z',
        'usuario_id': '99',
      });

      final entity = model.toEntity();

      expect(entity.id, 15);
      expect(entity.areaDireito, 'Direito Civil');
      expect(entity.pedidosPrincipais, 'Pedidos principais');
      expect(entity.tesePretendida, 'Tese pretendida');
      expect(entity.uf, 'SP');
      expect(entity.fatosEstruturados, 'Fatos estruturados');
      expect(entity.fundamentosJuridicos, 'Fundamentos jurídicos');
      expect(entity.tribunalPrecedenteId, 7);
      expect(entity.createdAt, DateTime.parse('2026-05-28T10:00:00.000Z'));
      expect(entity.usuarioId, 99);
    });
  });
}
