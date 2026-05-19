import '../entities/history.dart';

abstract class HistoryRepository {
  Future<List<AnalysisHistory>> getAll();
}