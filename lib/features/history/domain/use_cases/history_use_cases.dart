import '../entities/history.dart';
import '../repositories/history_repository.dart';

class GetAllHistoryUseCase {
  final HistoryRepository repository;
  GetAllHistoryUseCase(this.repository);
  Future<List<AnalysisHistory>> execute() => repository.getAll();
}

class SaveHistoryUseCase {
  final HistoryRepository repository;
  SaveHistoryUseCase(this.repository);
  Future<void> execute(AnalysisHistory history) => repository.save(history);
}

class DeleteHistoryUseCase {
  final HistoryRepository repository;
  DeleteHistoryUseCase(this.repository);
  Future<void> execute(String id) => repository.delete(id);
}

class ClearAllHistoryUseCase {
  final HistoryRepository repository;
  ClearAllHistoryUseCase(this.repository);
  Future<void> execute() => repository.clearAll();
}