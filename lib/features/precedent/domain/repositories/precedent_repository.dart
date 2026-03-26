import '../entities/precedent.dart';
import '../entities/precedent_suggested.dart';

abstract class PrecedentRepository {
  Future<List<PrecedentSuggested>> getSuggestedPrecedents({int? petitionId});

  Future<PrecedentSuggested?> getSuggestedPrecedentById(int id);

  Future<List<Precedent>> getPrecedents();

  Future<Precedent?> getPrecedentById(int id);
}
