import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cookiecutter/features/account/domain/entities/user.dart';
import 'package:flutter_cookiecutter/routes/app_router.dart';

void main() {
  group('AppRouter Navigation Items Tests', () {
    test('should return correct items for Juiz', () {
      final user = User(
        accessToken: 't',
        id: 1,
        nome: 'N',
        sobrenome: 'S',
        email: 'e',
        role: 'juiz',
      );

      final items = AppRouter.getHomeBottomItems(user);
      
      expect(items.length, 3);
      expect(items[0].label, 'Home');
      expect(items[1].label, 'Histórico');
      expect(items[2].label, 'Perfil');
    });

    test('should return correct items for Advogado', () {
      final user = User(
        accessToken: 't',
        id: 1,
        nome: 'N',
        sobrenome: 'S',
        email: 'e',
        role: 'advogado',
      );

      final items = AppRouter.getHomeBottomItems(user);
      
      expect(items.length, 2);
      expect(items[0].label, 'Home');
      expect(items[1].label, 'Perfil');
    });

    test('should return 3 items for common User', () {
      final user = User(
        accessToken: 't',
        id: 1,
        nome: 'N',
        sobrenome: 'S',
        email: 'e',
        role: 'user',
      );

      final items = AppRouter.getHomeBottomItems(user);
      
      expect(items.length, 3);
      expect(items[0].label, 'Home');
      expect(items[1].label, 'Histórico');
      expect(items[2].label, 'Perfil');
    });

    test('should return 2 items when user is null', () {
      final items = AppRouter.getHomeBottomItems(null);
      
      expect(items.length, 2);
      expect(items[0].label, 'Home');
      expect(items[1].label, 'Perfil');
    });
  });
}
