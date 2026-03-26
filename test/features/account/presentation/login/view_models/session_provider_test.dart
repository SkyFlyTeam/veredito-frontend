import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';
import 'package:flutter_cookiecutter/features/account/presentation/login/providers/session_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
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
        final user = User(accessToken: 'token-valido');

        container.read(sessionProvider.notifier).setUser(user);

        expect(container.read(sessionProvider), isNotNull);
        expect(container.read(sessionProvider)?.accessToken, 'token-valido');
      });

      test('deve marcar como autenticado após setUser', () {
        final user = User(accessToken: 'token-valido');

        container.read(sessionProvider.notifier).setUser(user);

        expect(container.read(isAuthenticatedProvider), true);
      });
    });

    group('clearUser', () {
      test('deve limpar o usuário da sessão', () {
        final user = User(accessToken: 'token-valido');
        container.read(sessionProvider.notifier).setUser(user);

        container.read(sessionProvider.notifier).clearUser();

        expect(container.read(sessionProvider), isNull);
      });

      test('deve marcar como não autenticado após clearUser', () {
        final user = User(accessToken: 'token-valido');
        container.read(sessionProvider.notifier).setUser(user);

        container.read(sessionProvider.notifier).clearUser();

        expect(container.read(isAuthenticatedProvider), false);
      });
    });
  });
}