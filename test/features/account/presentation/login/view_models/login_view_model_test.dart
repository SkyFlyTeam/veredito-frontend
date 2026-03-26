import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/login_usecase.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/view_models/login_view_model.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/providers/session_provider.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/providers/login_usecase_provider.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class FakeStorage extends FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    String? value,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data[key] = value ?? '';
  }

  @override
  Future<String?> read({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AndroidOptions? aOptions,
    IOSOptions? iOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

User _makeUser() => User(
      accessToken: 'token-valido',
      id: 1,
      nome: 'Dev',
      sobrenome: 'Local',
      email: 'teste@exemplo.com',
      role: 'superuser',
    );

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
  late ProviderContainer container;
  late LoginViewModel viewModel;

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();

    container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(
          (ref) => SessionNotifier(storage: FakeStorage()),
        ),
        loginViewModelProvider.overrideWith(
          (ref) => LoginViewModel(mockLoginUsecase, ref),
        ),
      ],
    );

    viewModel = container.read(loginViewModelProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('loginViewModel', () {
    group('resultado do login', () {
      test('deve fazer login com sucesso', () async {
        when(
          () => mockLoginUsecase.execute('teste@exemplo.com', '123456'),
        ).thenAnswer((_) async => _makeUser());

        await viewModel.login('  teste@exemplo.com  ', '123456');

        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.error, isNull);

        // garante que usuário foi salvo na sessão
        expect(container.read(sessionProvider), isNotNull);

        verify(
          () => mockLoginUsecase.execute('teste@exemplo.com', '123456'),
        ).called(1);
      });
    });
  });
}