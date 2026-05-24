import '../entities/history.dart';
import '../repositories/history_repository.dart';

class GetAllHistoryUseCase {
  final HistoryRepository repository;
  GetAllHistoryUseCase(this.repository);
  Future<List<AnalysisHistory>> execute() => repository.getAll();
}