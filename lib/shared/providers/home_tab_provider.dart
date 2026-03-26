import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls which tab is currently visible in the home shell.
/// 0 = Upload, 1 = History, 2 = Profile
final homeTabProvider = StateProvider<int>((ref) => 0);
