import '../repositories/petition_repository.dart';

class UploadPetitionUsecase {
  final PetitionRepository _repository;

  const UploadPetitionUsecase(this._repository);

  Future<void> execute(String fileName, List<int> bytes) {
    return _repository.uploadPetition(fileName, bytes);
  }
}
