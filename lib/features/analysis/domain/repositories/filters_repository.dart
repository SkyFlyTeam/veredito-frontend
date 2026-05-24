import '../entities/especie_precedente.dart';
import '../entities/tribunal_precedente.dart';

abstract class FiltersRepository {
  Future<List<EspeciePrecedente>> fetchEspecies();
  Future<List<TribunalPrecedente>> fetchTribunais();
}
