import '../../../../../core/utils/date_formater.dart';
import '../../../../../core/utils/text_formater.dart';
import '../../../data/models/pipeline_event_model.dart';
import '../../../domain/entities/precedent_suggested.dart';

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
    final numeroRegistroSplit =
        precedent.numero_registro.trim().split('-').last;


    return PrecedentCardData(
      precedentId: precedent.id,
      title: 'Nº $numeroRegistroSplit',
      tribunalSigla: 'T${precedent.tribunal_id}',
      status: 'Em análise',
      dataAtualizacao: '',
      thesis: removeHtmlTags(precedent.tese),
      percentualSimilaridade: synthesis?.percentual_similaridade ?? 0.0,
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