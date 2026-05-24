import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';

void main() {
  group('UserRoleX Extension Tests', () {
    test('should return isJuiz true when role is juiz', () {
      final user = User(
        accessToken: 't',
        id: 1,
        nome: 'N',
        sobrenome: 'S',
        email: 'e',
        role: 'juiz',
      );
      expect(user.isJuiz, isTrue);
      expect(user.isAdvogado, isFalse);
      expect(user.isUser, isFalse);
    });

    test('should return isAdvogado true when role is advogado', () {
      final user = User(
        accessToken: 't',
        id: 1,
        nome: 'N',
        sobrenome: 'S',
        email: 'e',
        role: 'advogado',
      );
      expect(user.isJuiz, isFalse);
      expect(user.isAdvogado, isTrue);
      expect(user.isUser, isFalse);
    });

    test('should return isUser true when role is user', () {
      final user = User(
        accessToken: 't',
        id: 1,
        nome: 'N',
        sobrenome: 'S',
        email: 'e',
        role: 'user',
      );
      expect(user.isJuiz, isFalse);
      expect(user.isAdvogado, isFalse);
      expect(user.isUser, isTrue);
    });

    test('should be case insensitive', () {
      final user = User(
        accessToken: 't',
        id: 1,
        nome: 'N',
        sobrenome: 'S',
        email: 'e',
        role: 'JUIZ',
      );
      expect(user.isJuiz, isTrue);
    });
  });
}
