import '../../../petition/domain/entities/peticao.dart';
import '../entities/analyze_petition_result.dart';
import '../entities/precedent.dart';
import '../entities/precedent_suggested.dart';

abstract class PrecedentRepository {
  Future<AnalyzePetitionResult> analyzePetition(Peticao petition);

  Future<List<PrecedentSuggested>> getSuggestedPrecedents({int? petitionId});

  Future<PrecedentSuggested?> getSuggestedPrecedentById(int id);

  Future<List<Precedent>> getPrecedents();

  Future<Precedent?> getPrecedentById(int id);
}
