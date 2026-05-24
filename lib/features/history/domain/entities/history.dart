import '../../../precedent/domain/entities/precedent_suggested.dart';

class AnalysisHistory {
  final int petitionId;
  final String fileName;
  final String? resumo;
  final List<PrecedentSuggested> suggestions;
  final DateTime analyzedAt;

  const AnalysisHistory({
    required this.petitionId,
    required this.fileName,
    this.resumo,
    required this.suggestions,
    required this.analyzedAt,
  });

  int get completedSuggestions =>
      suggestions.where((s) => s.hasSinteseExplicativa).length;

  bool get hasAnySuggestion => suggestions.isNotEmpty;
}