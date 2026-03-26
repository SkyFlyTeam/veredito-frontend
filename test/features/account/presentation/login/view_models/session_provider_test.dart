import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/providers/session_provider.dart';

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

void main() {
  late ProviderContainer container;

  User _makeUser() => User(
        accessToken: 'token-valido',
        id: 1,
        nome: 'Dev',
        sobrenome: 'Local',
        email: 'teste@exemplo.com',
        role: 'superuser',
      );

  setUp(() {
    container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith(
          (ref) => SessionNotifier(storage: FakeStorage()),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('sessionProvider', () {
    group('estado inicial', () {
      test('deve começar sem usuário logado', () {
        expect(container.read(sessionProvider), isNull);
      });

      test('deve começar como não autenticado', () {
        expect(container.read(isAuthenticatedProvider), false);
      });
    });

    group('setUser', () {
      test('deve popular o usuário na sessão', () {
        final user = _makeUser();

        container.read(sessionProvider.notifier).setUser(user);

        expect(container.read(sessionProvider), isNotNull);
        expect(container.read(sessionProvider)?.accessToken, 'token-valido');
      });

      test('deve marcar como autenticado após setUser', () {
        final user = _makeUser();

        container.read(sessionProvider.notifier).setUser(user);

        expect(container.read(isAuthenticatedProvider), true);
      });
    });

    group('clearUser', () {
      test('deve limpar o usuário da sessão', () {
        final user = _makeUser();
        container.read(sessionProvider.notifier).setUser(user);

        container.read(sessionProvider.notifier).clearUser();

        expect(container.read(sessionProvider), isNull);
      });

      test('deve marcar como não autenticado após clearUser', () {
        final user = _makeUser();
        container.read(sessionProvider.notifier).setUser(user);

        container.read(sessionProvider.notifier).clearUser();

        expect(container.read(isAuthenticatedProvider), false);
      });
    });
  });
}