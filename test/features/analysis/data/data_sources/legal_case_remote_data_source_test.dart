import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_cookiecutter/features/analysis/data/data_sources/legal_case_remote_data_source.dart';
import 'package:flutter_cookiecutter/features/analysis/data/models/legal_case_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDio dio;
  late LegalCaseRemoteDataSource dataSource;

  setUp(() {
    dio = MockDio();
    dataSource = LegalCaseRemoteDataSource(dio);
  });

  group('LegalCaseRemoteDataSource', () {
    test(
      'normaliza a extensao do arquivo antes de enviar no multipart',
      () async {
        when(
          () => dio.post('/caso-juridico', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            requestOptions: RequestOptions(path: '/caso-juridico'),
            data: {
              'id': 1,
              'area_direito': 'Direito Civil',
              'pedidos_principais': 'Pedidos',
              'tese_pretendida': 'Tese',
              'uf': 'SP',
              'fatos_estruturados': 'Fatos',
              'fundamentos_juridicos': 'Fundamentos',
              'tribunalPrecedenteId': 7,
              'createdAt': '2026-05-29T00:00:00.000Z',
              'usuarioId': 99,
            },
          ),
        );

        await dataSource.create(
          areaDireito: 'Direito Civil',
          pedidosPrincipais: 'Pedidos',
          tesePretendida: 'Tese',
          fatosEstruturados: 'Fatos',
          fundamentosJuridicos: 'Fundamentos',
          uf: 'SP',
          tribunalPrecedenteId: 7,
          files: [
            {
              'name': 'A\u00c7\u00c3O POPULAR.PDF',
              'bytes': Uint8List.fromList([1, 2, 3]),
            },
          ],
        );

        final verification = verify(
          () => dio.post('/caso-juridico', data: captureAny(named: 'data')),
        );

        final formData = verification.captured.single as FormData;
        final fields = Map<String, String>.fromEntries(formData.fields);

        expect(fields['area_direito'], 'Direito Civil');
        expect(fields['pedidos_principais'], 'Pedidos');
        expect(fields['tese_pretendida'], 'Tese');
        expect(fields['fatos_estruturados'], 'Fatos');
        expect(fields['fundamentos_juridicos'], 'Fundamentos');
        expect(fields['uf'], 'SP');
        expect(fields['tribunalPrecedenteId'], '7');
        expect(formData.files, hasLength(1));
        expect(
          formData.files.single.value.filename,
          'A\u00c7\u00c3O POPULAR.pdf',
        );
      },
    );

    test(
      'retorna o modelo do caso juridico a partir da resposta da api',
      () async {
        when(
          () => dio.post('/caso-juridico', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            requestOptions: RequestOptions(path: '/caso-juridico'),
            data: {
              'id': 1,
              'area_direito': 'Direito Civil',
              'pedidos_principais': 'Pedidos',
              'tese_pretendida': 'Tese',
              'uf': 'SP',
              'fatos_estruturados': 'Fatos',
              'fundamentos_juridicos': 'Fundamentos',
              'tribunalPrecedenteId': 7,
              'createdAt': '2026-05-29T00:00:00.000Z',
              'usuarioId': 99,
            },
          ),
        );

        final model = await dataSource.create(
          areaDireito: 'Direito Civil',
          pedidosPrincipais: 'Pedidos',
          tesePretendida: 'Tese',
          fatosEstruturados: 'Fatos',
          fundamentosJuridicos: 'Fundamentos',
          uf: 'SP',
          tribunalPrecedenteId: 7,
          files: [
            {
              'name': 'documento.pdf',
              'bytes': Uint8List.fromList([1, 2, 3]),
            },
          ],
        );

        expect(model, isA<LegalCaseModel>());
        expect(model.toEntity().fatosEstruturados, 'Fatos');
        expect(model.toEntity().fundamentosJuridicos, 'Fundamentos');
      },
    );
  });
}
