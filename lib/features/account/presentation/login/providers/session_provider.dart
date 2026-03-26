import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../../domain/entities/user.dart';

class SessionNotifier extends StateNotifier<User?> {
  final FlutterSecureStorage _storage;

  SessionNotifier({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(null);

  static const _userKey = 'user_data';

  void setUser(User user) {
    state = user;
    _persistUser(user);
  }

  void clearUser() {
    state = null;
    _storage.delete(key: _userKey);
  }

  Future<void> restoreSession() async {
    final userData = await _storage.read(key: _userKey);
    if (userData == null) return;

    final json = jsonDecode(userData) as Map<String, dynamic>;

    state = User(
      accessToken: json['accessToken'] as String,
      id: json['id'] as int,
      nome: json['nome'] as String,
      sobrenome: json['sobrenome'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Future<void> _persistUser(User user) async {
    final json = jsonEncode({
      'accessToken': user.accessToken,
      'id': user.id,
      'nome': user.nome,
      'sobrenome': user.sobrenome,
      'email': user.email,
      'role': user.role,
    });

    await _storage.write(key: _userKey, value: json);
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, User?>(
  (ref) => SessionNotifier(),
);

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(sessionProvider) != null,
);