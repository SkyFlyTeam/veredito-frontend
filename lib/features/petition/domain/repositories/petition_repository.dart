abstract class PetitionRepository {
  Future<void> uploadPetition(String fileName, List<int> bytes);
}
