import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/history_data_source.dart';
import '../../../data/repositories/history_repository_impl.dart';
import '../../../domain/use_cases/history_use_cases.dart';
import '../view_models/history_state.dart';
import '../view_models/history_view_model.dart';

final historyViewModelProvider =
    StateNotifierProvider<HistoryViewModel, HistoryState>((ref) {
      final dio = ref.read(apiClientProvider).dio;
      final dataSource = HistoryDataSource(dio);
      final repository = HistoryRepositoryImpl(dataSource);
      final getAllUseCase = GetAllHistoryUseCase(repository);

      return HistoryViewModel(getAllUseCase);
    });