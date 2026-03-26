import '../entities/precedent_suggested.dart';
import '../repositories/precedent_repository.dart';

class GetPrecedentSuggestionsUsecase {
  final PrecedentRepository repository;

  GetPrecedentSuggestionsUsecase(this.repository);

  Future<List<PrecedentSuggested>> execute({int? petitionId}) {
    return repository.getSuggestedPrecedents(petitionId: petitionId);
  }
}
