import '../../domain/repositories/filters_repository.dart';
import '../data_sources/filters_remote_data_source.dart';
import '../../domain/entities/especie_precedente.dart';
import '../../domain/entities/tribunal_precedente.dart';

class FiltersRepositoryImpl implements FiltersRepository {
  final FiltersRemoteDataSource dataSource;

  FiltersRepositoryImpl(this.dataSource);

  @override
  Future<List<EspeciePrecedente>> fetchEspecies() async {
    final especies = await dataSource.fetchEspecies();
    return especies.map((item) => item.toEntity()).toList(growable: false);
  }

  @override
  Future<List<TribunalPrecedente>> fetchTribunais() async {
    final tribunais = await dataSource.fetchTribunais();
    return tribunais.map((item) => item.toEntity()).toList(growable: false);
  }
}
