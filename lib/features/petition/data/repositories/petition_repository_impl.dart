import '../../domain/entities/peticao.dart';
import '../../domain/repositories/petition_repository.dart';
import '../data_sources/petition_remote_data_source.dart';

class PetitionRepositoryImpl implements PetitionRepository {
  final PetitionRemoteDataSource _dataSource;

  const PetitionRepositoryImpl(this._dataSource);

  @override
  Future<Peticao> uploadPetition(
    String fileName,
    List<int> bytes, {
    void Function(double)? onProgress,
  }) async {
    final petitionModel = await _dataSource.uploadPetition(
      fileName,
      bytes,
      onProgress: onProgress,
    );
    return petitionModel.toEntity();
  }
}
