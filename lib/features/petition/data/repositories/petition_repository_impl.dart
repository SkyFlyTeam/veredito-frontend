import '../../domain/repositories/petition_repository.dart';
import '../data_sources/petition_remote_data_source.dart';

class PetitionRepositoryImpl implements PetitionRepository {
  final PetitionRemoteDataSource _dataSource;

  const PetitionRepositoryImpl(this._dataSource);

  @override
  Future<void> uploadPetition(
    String fileName,
    List<int> bytes, {
    void Function(double)? onProgress,
  }) {
    return _dataSource.uploadPetition(fileName, bytes, onProgress: onProgress);
  }
}
