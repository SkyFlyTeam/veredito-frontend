import '../entities/history.dart';


abstract class HistoryRepository {

  Future<List<AnalysisHistory>> getAll();


  Future<void> save(AnalysisHistory history);


  Future<void> delete(String id);


  Future<void> clearAll();
}