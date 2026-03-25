import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';
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

  group('login validation', () {
    test('deve retornar erro quando email e senha estiverem vazios', () async {
      await viewModel.login('', '');

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, 'Email ou Senha incorretos.');
      verifyNever(() => mockLoginUsecase.execute(any(), any()));
    });

    test('deve retornar erro quando apenas email estiver vazio', () async {
      await viewModel.login('', '123456');

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, 'Email ou Senha incorretos.');
      verifyNever(() => mockLoginUsecase.execute(any(), any()));
    });

    test('deve retornar erro quando apenas senha estiver vazia', () async {
      await viewModel.login('teste@exemplo.com', '');

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, 'Email ou Senha incorretos.');
      verifyNever(() => mockLoginUsecase.execute(any(), any()));
    });

    test('deve retornar erro quando email for invalido', () async {
      await viewModel.login('email-invalido', '123456');

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, 'Email ou senha incorretos.');
      verifyNever(() => mockLoginUsecase.execute(any(), any()));
    });
  });

  group('login result', () {
    test('deve fazer login com sucesso', () async {
      when(
        () => mockLoginUsecase.execute('teste@exemplo.com', '123456'),
      ).thenAnswer((_) async => User(accessToken: 'token-valido'));

      await viewModel.login('  teste@exemplo.com  ', '123456');

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, isNull);
      verify(
        () => mockLoginUsecase.execute('teste@exemplo.com', '123456'),
      ).called(1);
    });

    test('deve retornar erro de credenciais para status 401', () async {
      when(
        () => mockLoginUsecase.execute('teste@exemplo.com', '123456'),
      ).thenThrow(_dioException(statusCode: 401));

      await viewModel.login('teste@exemplo.com', '123456');

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, 'Email ou senha incorretos.');
      verify(
        () => mockLoginUsecase.execute('teste@exemplo.com', '123456'),
      ).called(1);
    });

    test('deve retornar erro generico para outros erros de rede', () async {
      when(
        () => mockLoginUsecase.execute('teste@exemplo.com', '123456'),
      ).thenThrow(_dioException(type: DioExceptionType.connectionError));

      await viewModel.login('teste@exemplo.com', '123456');

      expect(viewModel.state.isLoading, false);
      expect(
        viewModel.state.error,
        'Erro ao logar. Por favor, tente novamente',
      );
      verify(
        () => mockLoginUsecase.execute('teste@exemplo.com', '123456'),
      ).called(1);
    });

    test('deve retornar falha no login para erros inesperados', () async {
      when(
        () => mockLoginUsecase.execute('teste@exemplo.com', '123456'),
      ).thenThrow(Exception('erro inesperado'));

      await viewModel.login('teste@exemplo.com', '123456');

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, 'Falha no login.');
      verify(
        () => mockLoginUsecase.execute('teste@exemplo.com', '123456'),
      ).called(1);
    });
  });
}
