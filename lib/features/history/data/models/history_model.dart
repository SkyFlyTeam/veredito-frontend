import '../../../../core/utils/file_name_parser.dart';
import '../../../../core/utils/values_conversor.dart';
import '../../../precedent/data/models/precedent_suggested_model.dart';
import '../../../precedent/domain/entities/precedent_suggested.dart';
import '../../domain/entities/history.dart';

class AnalysisHistoryModel {
  final int petitionId;
  final String fileName;
  final String? resumo;
  final DateTime analyzedAt;
  final List<PrecedentSuggested> suggestions;

  const AnalysisHistoryModel({
    required this.petitionId,
    required this.fileName,
    this.resumo,
    required this.analyzedAt,
    this.suggestions = const [],
  });

  /// Constrói a partir do JSON de GET /peticao
  factory AnalysisHistoryModel.fromJson(Map<String, dynamic> json) {
    return AnalysisHistoryModel(
      petitionId: valueToInt(json['id']) ?? 0,
      fileName: extractOriginalFileNameFromPath(
        json['caminhoArquivo'] as String? ?? '',
      ),
      resumo: json['resumo'] as String?,
      analyzedAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Retorna uma cópia com as sugestões preenchidas
  AnalysisHistoryModel withSuggestions(List<PrecedentSuggested> suggestions) {
    return AnalysisHistoryModel(
      petitionId: petitionId,
      fileName: fileName,
      resumo: resumo,
      analyzedAt: analyzedAt,
      suggestions: suggestions,
    );
  }

  AnalysisHistory toEntity() {
    return AnalysisHistory(
      petitionId: petitionId,
      fileName: fileName,
      resumo: resumo,
      analyzedAt: analyzedAt,
      suggestions: suggestions,
    );
  }
}