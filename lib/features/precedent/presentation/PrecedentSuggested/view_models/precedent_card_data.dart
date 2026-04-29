import '../../../../../core/utils/text_formater.dart';
import '../../../data/models/pipeline_event_model.dart';
import '../../../domain/entities/precedent_suggested.dart';
import 'package:flutter/foundation.dart';
class PrecedentCardData {
  final int precedentId;
  final String title;
  final String tribunalSigla;
  final String status;
  final String dataAtualizacao;
  final String thesis;
  final double percentualSimilaridade;
  final int? classificacao;
  final String? sinteseExplicativa;
  final bool isLoading;

  const PrecedentCardData({
    required this.precedentId,
    required this.title,
    required this.tribunalSigla,
    required this.status,
    required this.dataAtualizacao,
    required this.thesis,
    required this.percentualSimilaridade,
    required this.classificacao,
    required this.sinteseExplicativa,
    required this.isLoading,
  });

  factory PrecedentCardData.fromSuggested(PrecedentSuggested s) {
    return PrecedentCardData(
      precedentId: s.precedentId,
      title: s.title,
      tribunalSigla: s.tribunalSigla,
      status: s.status,
      dataAtualizacao: s.dataAtualizacao,
      thesis: s.thesis,
      percentualSimilaridade: s.percentualSimilaridade,
      classificacao: s.classificacao,
      sinteseExplicativa: s.sinteseExplicativa,
      isLoading: false,
    );
  }

  factory PrecedentCardData.fromSSE({
    required PrecedentBackendDto precedent,
    SynthesisEvent? synthesis,
  }) {
    final numeroRegistro = precedent.numero_registro.trim().split('-').last;
    final especieNome = precedent.especie_nome ?? 'Espécie desconhecida';
    final tribunalSigla =
        _extractTribunalInitials(precedent.tribunal_nome) ??
        'Tribunal desconhecido';
    final statusNome = precedent.status_nome ?? 'Status desconhecido';
    debugPrint('ultima_atualizacao raw: ${precedent.ultima_atualizacao}');
    debugPrint(
      'dataAtualizacao formatada: ${_formatDate(precedent.ultima_atualizacao)}',
    );
    return PrecedentCardData(
      precedentId: precedent.id,
      title: '$especieNome n° $numeroRegistro',
      tribunalSigla: tribunalSigla,
      status: statusNome,
      dataAtualizacao: _formatDate(precedent.ultima_atualizacao),
      thesis: removeHtmlTags(precedent.tese ?? precedent.questao ?? ''),
      percentualSimilaridade:
          synthesis?.percentual_similaridade ??
          precedent.percentualSimilaridade,
      classificacao: synthesis?.classificacao,
      sinteseExplicativa: synthesis?.sintese_explicativa,
      isLoading: synthesis == null,
    );
  }

  bool get hasSinteseExplicativa =>
      sinteseExplicativa?.trim().isNotEmpty ?? false;

  String get percentualSimilaridadePercentage =>
      '${percentualSimilaridade.toStringAsFixed(2)}%';

  String get sinteseExplicativaText =>
      sinteseExplicativa ?? 'Sem síntese explicativa disponível.';
}

String? _extractTribunalInitials(String? tribunalNome) {
  if (tribunalNome == null || tribunalNome.trim().isEmpty) {
    return null;
  }

  final palavrasIgnoradas = {'de', 'do', 'dos', 'da', 'das', 'e'};
  final words = tribunalNome.trim().split(RegExp(r'\s+'));
  final initials = words
      .where(
        (word) =>
            word.isNotEmpty && !palavrasIgnoradas.contains(word.toLowerCase()),
      )
      .map((word) => word[0].toUpperCase())
      .join();

  return initials.isNotEmpty ? initials : null;
}

String _formatDate(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return '';
  // Garante que parseia como UTC mesmo sem o 'Z' no final
  final normalized = dateStr.endsWith('Z') ? dateStr : '${dateStr}Z';
  final date = DateTime.tryParse(normalized);
  if (date == null) return '';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}