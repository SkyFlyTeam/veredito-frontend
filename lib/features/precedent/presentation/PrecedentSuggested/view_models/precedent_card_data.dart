import '../../../../../core/utils/text_formater.dart';
import '../../../data/models/pipeline_event_model.dart';
import '../../../domain/entities/precedent_suggested.dart';

String _formatNumeroRegistro(String numeroRegistro) {
  final trimmed = numeroRegistro.trim();
  if (trimmed.isEmpty) return 'Precedente';

  final parts = trimmed.split('-');
  if (parts.length < 2) return trimmed; // Retorna como está

  // Última parte é o número
  final numero = parts.last;
  // Outras partes ficam em uppercase com espaço
  final sigla = parts.sublist(0, parts.length - 1).join(' ').toUpperCase();

  return '$sigla n° $numero';
}

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
    return PrecedentCardData(
      precedentId: precedent.id,
      title: _formatNumeroRegistro(precedent.numero_registro),
      tribunalSigla: precedent.tribunal_id != null
          ? 'T${precedent.tribunal_id}'
          : 'Tribunal',
      status: 'Em análise',
      dataAtualizacao: '',
      thesis: removeHtmlTags(precedent.tese ?? precedent.questao ?? ''),
      percentualSimilaridade:
          precedent.percentualSimilaridade, // calculado do score
      classificacao: synthesis?.classificacao, // null até SynthesisEvent chegar
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
