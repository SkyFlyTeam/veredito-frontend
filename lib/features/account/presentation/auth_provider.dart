import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/user.dart';

final currentUserProvider = StateProvider<User?>((ref) => null);
