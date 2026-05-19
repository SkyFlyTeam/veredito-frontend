import '../../domain/entities/history.dart';
import '../../domain/repositories/history_repository.dart';
import '../data_sources/history_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDataSource _dataSource;

  HistoryRepositoryImpl(this._dataSource);

  @override
  Future<List<AnalysisHistory>> getAll() async {
    final peticoes = await _dataSource.getAll();

    final result = await Future.wait(
      peticoes.map((peticao) async {
        final suggestions = await _dataSource.getByPeticao(peticao.petitionId);

        return peticao
            .withSuggestions(suggestions.map((s) => s.toEntity()).toList())
            .toEntity();
      }),
    );

    return result;
  }
}