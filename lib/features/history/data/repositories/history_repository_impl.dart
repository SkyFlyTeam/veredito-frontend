import '../../domain/entities/history.dart';
import '../../domain/repositories/history_repository.dart';
import '../data_sources/history_data_source.dart';
import '../models/history_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryDataSource _dataSource;

  HistoryRepositoryImpl(this._dataSource);

  @override
  Future<List<AnalysisHistory>> getAll() async {
    final models = await _dataSource.getAll();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> save(AnalysisHistory history) {
    return _dataSource.save(AnalysisHistoryModel.fromEntity(history));
  }

  @override
  Future<void> delete(String id) => _dataSource.delete(id);

  @override
  Future<void> clearAll() => _dataSource.clearAll();
}
