import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/get_user_usecase.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/update_user_usecase.dart';
import 'package:flutter_cookiecutter/features/account/domain/use_cases/logout_usecase.dart';
import 'package:flutter_cookiecutter/features/account/presentation/profile/view_models/profile_view_model.dart';
import 'package:flutter_cookiecutter/features/account/presentation/profile/providers/profile_provider.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/providers/session_provider.dart';

class MockGetUserUseCase extends Mock implements GetUserUseCase {}

class MockUpdateUserUseCase extends Mock implements UpdateUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

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
}

User _makeUser() => User(
  accessToken: 'token-valido',
  id: 3,
  nome: 'Guilherme',
  sobrenome: 'Benedito',
  email: 'guilherme@fatec.com',
  role: 'superuser',
);

void main() {
  late MockGetUserUseCase mockGetUser;
  late MockUpdateUserUseCase mockUpdateUser;
  late MockLogoutUseCase mockLogout;
  late ProviderContainer container;
  late ProfileViewModel viewModel;

  setUp(() {
    mockGetUser = MockGetUserUseCase();
    mockUpdateUser = MockUpdateUserUseCase();
    mockLogout = MockLogoutUseCase();

    container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(
          (ref) => SessionNotifier(storage: FakeStorage()),
        ),
        profileViewModelProvider.overrideWith(
          (ref) => ProfileViewModel(
            getUserUseCase: mockGetUser,
            updateUserUseCase: mockUpdateUser,
            logoutUseCase: mockLogout,
            ref: ref,
          ),
        ),
      ],
    );

    viewModel = container.read(profileViewModelProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('ProfileViewModel', () {
    test('carrega perfil com sucesso', () async {
      final user = _makeUser();
      when(() => mockGetUser.execute(any())).thenAnswer((_) async => user);

      await viewModel.loadProfile(3);

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.user, user);
      verify(() => mockGetUser.execute(3)).called(1);
    });

    test(
      'tenta atualizar perfil com campo Nome vazio e falha na validação',
      () async {
        await viewModel.updateProfile(3, '', 'email@teste.com', null);

        expect(viewModel.state.isSaving, false);
        expect(viewModel.state.error, contains('O campo Nome é obrigatório'));
        verifyNever(() => mockUpdateUser.execute(any(), any()));
      },
    );

    test(
      'tenta atualizar perfil com campo Email vazio e falha na validação',
      () async {
        await viewModel.updateProfile(3, 'Guilherme', '', null);

        expect(viewModel.state.isSaving, false);
        expect(viewModel.state.error, contains('O campo Email é obrigatório'));
        verifyNever(() => mockUpdateUser.execute(any(), any()));
      },
    );
    test('exibe erro do backend ao tentar usar email duplicado', () async {
      when(() => mockUpdateUser.execute(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            data: {'message': 'Email já cadastrado'},
            statusCode: 409,
          ),
        ),
      );

      await viewModel.updateProfile(
        3,
        'Guilherme',
        'guilherme@gmail.com',
        null,
      );

      expect(viewModel.state.isSaving, false);
      expect(viewModel.state.error, 'Email já cadastrado');
    });

    test('faz logout com sucesso', () async {
      when(() => mockLogout.execute()).thenAnswer((_) async {});

      await viewModel.logout();

      verify(() => mockLogout.execute()).called(1);
    });
  });
}
