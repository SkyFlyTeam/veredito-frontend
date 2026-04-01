import '../entities/peticao.dart';
import '../repositories/petition_repository.dart';

class UploadPetitionUsecase {
  final PetitionRepository _repository;

  const UploadPetitionUsecase(this._repository);

  Future<Peticao> execute(
    String fileName,
    List<int> bytes, {
    void Function(double)? onProgress,
  }) {
    return _repository.uploadPetition(fileName, bytes, onProgress: onProgress);
  }
}
