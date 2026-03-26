import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/user.dart';

class SessionNotifier extends StateNotifier<User?> {
  SessionNotifier() : super(null);

  void setUser(User user) => state = user;
  void clearUser() => state = null;
}

final sessionProvider = StateNotifierProvider<SessionNotifier, User?>(
  (ref) => SessionNotifier(),
);

// Use esse provider quando só precisar saber se está logado
final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(sessionProvider) != null,
);