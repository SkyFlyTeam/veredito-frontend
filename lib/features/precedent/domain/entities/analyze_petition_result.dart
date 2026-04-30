import 'precedent_suggested.dart';

class AnalyzePetitionResult {
  final int petitionId;
  final String? summary;
  final List<PrecedentSuggested> suggestions;

  const AnalyzePetitionResult({
    required this.petitionId,
    required this.summary,
    required this.suggestions,
  });
}
