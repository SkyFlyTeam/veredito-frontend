import '../../../petition/domain/entities/peticao.dart';
import '../entities/analyze_petition_result.dart';
import '../repositories/precedent_repository.dart';

class AnalyzePetitionUsecase {
  final PrecedentRepository repository;

  AnalyzePetitionUsecase(this.repository);

  Future<AnalyzePetitionResult> execute(Peticao petition) {
    return repository.analyzePetition(petition);
  }
}
