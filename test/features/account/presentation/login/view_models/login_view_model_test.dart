import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_cookiecutter/features/account/domain/use_cases/login_usecase.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/view_models/login_view_model.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

DioException _dioException({
  int? statusCode,
  DioExceptionType type = DioExceptionType.unknown,
}) {
  return DioException(
    requestOptions: RequestOptions(path: '/auth/login'),
    response: statusCode == null
        ? null
        : Response(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: statusCode,
          ),
    type: type,
  );
}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late LoginViewModel viewModel;

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    viewModel = LoginViewModel(mockLoginUsecase);
  });

  test('deve retornar erro de conexao quando backend nao responder', () async {
    when(
      () => mockLoginUsecase.execute('teste@exemplo.com', '123456'),
    ).thenThrow(_dioException(type: DioExceptionType.connectionError));

    await viewModel.login('teste@exemplo.com', '123456');

    expect(viewModel.state.isLoading, false);
    expect(viewModel.state.error, 'Falha ao conectar com o servidor.');
    verify(
      () => mockLoginUsecase.execute('teste@exemplo.com', '123456'),
    ).called(1);
  });
}
