import '../repositories/filters_repository.dart';
import '../entities/especie_precedente.dart';
import '../entities/tribunal_precedente.dart';

class FiltersUseCase {
  final FiltersRepository repository;

  FiltersUseCase(this.repository);

  Future<List<EspeciePrecedente>> getEspecies() {
    return repository.fetchEspecies();
  }

  Future<List<TribunalPrecedente>> getTribunais() {
    return repository.fetchTribunais();
  }
}
