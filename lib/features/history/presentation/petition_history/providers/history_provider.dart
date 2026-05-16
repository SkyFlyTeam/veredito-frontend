import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/data_sources/history_data_source.dart';
import '../../../data/repositories/history_repository_impl.dart';
import '../view_models/history_view_model.dart';
import '../view_models/history_state.dart';
import '../../../domain/use_cases/history_use_cases.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Override sharedPreferencesProvider in main'),
);

final historyViewModelProvider =
    StateNotifierProvider<HistoryViewModel, HistoryState>((ref) {
      final prefs = ref.read(sharedPreferencesProvider);
      final dataSource = HistoryDataSource(prefs);
      final repository = HistoryRepositoryImpl(dataSource);
      final getAllUseCase = GetAllHistoryUseCase(repository);
      final saveUseCase = SaveHistoryUseCase(repository);
      final deleteUseCase = DeleteHistoryUseCase(repository);
      final clearAllUseCase = ClearAllHistoryUseCase(repository);

      return HistoryViewModel(
        getAllUseCase,
        saveUseCase,
        deleteUseCase,
        clearAllUseCase,
      );
    });
