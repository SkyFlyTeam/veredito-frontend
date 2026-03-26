import '../../domain/entities/precedent.dart';
import '../../domain/entities/precedent_suggested.dart';
import '../../domain/repositories/precedent_repository.dart';
import '../data_sources/precedent_remote_data_source.dart';

class PrecedentRepositoryImpl implements PrecedentRepository {
  final PrecedentRemoteDataSource dataSource;

  PrecedentRepositoryImpl(this.dataSource);

  @override
  Future<List<PrecedentSuggested>> getSuggestedPrecedents({
    int? petitionId,
  }) async {
    final models = await dataSource.getSuggestedPrecedents();
    final suggestions = models.map((model) => model.toEntity()).toList();

    if (petitionId == null) {
      return suggestions;
    }

    return suggestions
        .where((suggestion) => suggestion.petitionId == petitionId)
        .toList();
  }

  @override
  Future<PrecedentSuggested?> getSuggestedPrecedentById(int id) async {
    final model = await dataSource.getSuggestedPrecedentById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Precedent>> getPrecedents() async {
    final models = await dataSource.getPrecedents();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Precedent?> getPrecedentById(int id) async {
    final model = await dataSource.getPrecedentById(id);
    return model?.toEntity();
  }
}
