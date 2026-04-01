import '../entities/peticao.dart';

abstract class PetitionRepository {
  Future<Peticao> uploadPetition(
    String fileName,
    List<int> bytes, {
    void Function(double)? onProgress,
  });
}
