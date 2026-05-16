import '../../../precedent/domain/entities/precedent.dart';
import '../../../precedent/domain/entities/precedent_suggested.dart';
import '../../domain/entities/history.dart';


class AnalysisHistoryModel {
  final String id;
  final int petitionId;
  final String fileName;
  final String? resumo;
  final List<PrecedentSuggested> suggestions;
  final DateTime analyzedAt;

  const AnalysisHistoryModel({
    required this.id,
    required this.petitionId,
    required this.fileName,
    this.resumo,
    required this.suggestions,
    required this.analyzedAt,
  });

  factory AnalysisHistoryModel.fromEntity(AnalysisHistory entity) {
    return AnalysisHistoryModel(
      id: entity.id,
      petitionId: entity.petitionId,
      fileName: entity.fileName,
      resumo: entity.resumo,
      suggestions: entity.suggestions,
      analyzedAt: entity.analyzedAt,
    );
  }

  AnalysisHistory toEntity() {
    return AnalysisHistory(
      id: id,
      petitionId: petitionId,
      fileName: fileName,
      resumo: resumo,
      suggestions: suggestions,
      analyzedAt: analyzedAt,
    );
  }

  factory AnalysisHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawSuggestions = json['suggestions'] as List<dynamic>? ?? [];
    return AnalysisHistoryModel(
      id: json['id'] as String,
      petitionId: json['petitionId'] as int,
      fileName: json['fileName'] as String,
      resumo: json['resumo'] as String?,
      suggestions: rawSuggestions
          .map((e) => _parseSuggestion(e as Map<String, dynamic>))
          .toList(),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petitionId': petitionId,
      'fileName': fileName,
      'resumo': resumo,
      'suggestions': suggestions.map(_suggestionToJson).toList(),
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }


  static Map<String, dynamic> _suggestionToJson(PrecedentSuggested s) {
    return {
      'id': s.id,
      'petitionId': s.petitionId,
      'precedentId': s.precedentId,
      'percentualSimilaridade': s.percentualSimilaridade,
      'classificacao': s.classificacao,
      'sinteseExplicativa': s.sinteseExplicativa,
      'precedent': s.precedent == null ? null : _precedentToJson(s.precedent!),
    };
  }

  static Map<String, dynamic> _precedentToJson(Precedent p) {
    return {
      'id': p.id,
      'numeroRegistro': p.numeroRegistro,
      'tese': p.tese,
      'questao': p.questao,
      'ultimaAtualizacao': p.ultimaAtualizacao?.toIso8601String(),
      'tribunalNome': p.tribunalNome,
      'tribunalSigla': p.tribunalSigla,
      'statusNome': p.statusNome,
      'especieNome': p.especieNome,
      'especieSigla': p.especieSigla,
    };
  }

  static PrecedentSuggested _parseSuggestion(Map<String, dynamic> json) {
    final rawPrecedent = json['precedent'] as Map<String, dynamic>?;
    return PrecedentSuggested(
      id: json['id'] as int,
      petitionId: json['petitionId'] as int,
      precedentId: json['precedentId'] as int,
      percentualSimilaridade:
          (json['percentualSimilaridade'] as num).toDouble(),
      classificacao: json['classificacao'] as int?,
      sinteseExplicativa: json['sinteseExplicativa'] as String?,
      precedent: rawPrecedent == null ? null : _parsePrecedent(rawPrecedent),
    );
  }

  static Precedent _parsePrecedent(Map<String, dynamic> json) {
    return Precedent(
      id: json['id'] as int,
      numeroRegistro: json['numeroRegistro'] as String,
      tese: json['tese'] as String?,
      questao: json['questao'] as String?,
      ultimaAtualizacao: json['ultimaAtualizacao'] != null
          ? DateTime.tryParse(json['ultimaAtualizacao'] as String)
          : null,
      tribunalNome: json['tribunalNome'] as String?,
      tribunalSigla: json['tribunalSigla'] as String?,
      statusNome: json['statusNome'] as String?,
      especieNome: json['especieNome'] as String?,
      especieSigla: json['especieSigla'] as String?,
    );
  }
}
