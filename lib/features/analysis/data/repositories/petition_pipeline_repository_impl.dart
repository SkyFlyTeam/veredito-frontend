

import '../../domain/entities/precedent_stream_events/complete_event.dart';
import '../../domain/entities/precedent_stream_events/error_event.dart';
import '../../domain/entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../../domain/entities/precedent_stream_events/resumo_event.dart';
import '../../domain/entities/precedent_stream_events/search_event.dart';
import '../../domain/entities/precedent_stream_events/synthesis_event.dart';
import '../../domain/entities/precedent_suggested.dart';
import '../../domain/repositories/petition_pipeline_repository.dart';
import '../data_sources/petition_pipeline_remote_data_source.dart';
import '../models/precedent_stream_events/complete_event.dart' as data_models;
import '../models/precedent_stream_events/error_event.dart' as data_models;
import '../models/precedent_stream_events/precedent_stream_pipeline_event.dart' as data_models;
import '../models/precedente_sugerido.dart';
import '../models/precedent_stream_events/resumo_event.dart' as data_models;
import '../models/precedent_stream_events/search_event.dart' as data_models;
import '../models/precedent_stream_events/synthesis_event.dart' as data_models;

class PetitionPipelineRepositoryImpl implements PetitionPipelineRepository {
  final PetitionPipelineRemoteDataSource dataSource;

  PetitionPipelineRepositoryImpl(this.dataSource);

  @override
  Stream<PrecedentStreamPipelineEvent> streamPipeline(int peticaoId) {
    return dataSource
        .streamPipeline(peticaoId)
        .map((event) => _mapEvent(event, peticaoId));
  }

  @override
  void cancelStream(int peticaoId) {
    dataSource.cancelStream(peticaoId);
  }

  @override
  void cancelAll() {
    dataSource.cancelAll();
  }

  PrecedentStreamPipelineEvent _mapEvent(
    data_models.PrecedentStreamPipelineEvent event,
    int peticaoId,
  ) {
    switch (event) {
      case data_models.ResumoEvent resumoEvent:
        return ResumoEvent(
          stage: resumoEvent.stage,
          status: resumoEvent.status,
          timestamp: resumoEvent.timestamp,
          duration: resumoEvent.duration,
          resumo: resumoEvent.resumo,
        );
      case data_models.SearchEvent searchEvent:
        return SearchEvent(
          stage: searchEvent.stage,
          status: searchEvent.status,
          timestamp: searchEvent.timestamp,
          duration: searchEvent.duration,
          precedents: searchEvent.precedents
              .map((dto) => _mapSuggestion(dto, peticaoId))
              .toList(),
          totalFound: searchEvent.totalFound,
          averageSimilarityScore: searchEvent.averageSimilarityScore,
        );
      case data_models.SynthesisEvent synthesisEvent:
        return SynthesisEvent(
          stage: synthesisEvent.stage,
          status: synthesisEvent.status,
          timestamp: synthesisEvent.timestamp,
          duration: synthesisEvent.duration,
          id: synthesisEvent.id,
          classificacao: synthesisEvent.classificacao,
          sinteseExplicativa: synthesisEvent.sinteseExplicativa,
          precedenteId: synthesisEvent.precedenteId,
          entityId: synthesisEvent.entityId,
          percentualSimilaridade: synthesisEvent.percentualSimilaridade,
        );
      case data_models.ErrorEvent errorEvent:
        return ErrorEvent(
          stage: errorEvent.stage,
          status: errorEvent.status,
          timestamp: errorEvent.timestamp,
          duration: errorEvent.duration,
          failedStage: errorEvent.failedStage,
          message: errorEvent.message,
          errorCode: errorEvent.errorCode,
          precedentId: errorEvent.precedentId,
          recoverable: errorEvent.recoverable,
        );
      case data_models.CompleteEvent completeEvent:
        return CompleteEvent(
          stage: completeEvent.stage,
          status: completeEvent.status,
          timestamp: completeEvent.timestamp,
          duration: completeEvent.duration,
          totalDurationMs: completeEvent.totalDurationMs,
          precedentsProcessed: completeEvent.precedentsProcessed,
          synthesisGenerated: completeEvent.synthesisGenerated,
        );
      default:
        return PrecedentStreamPipelineEvent(
          stage: event.stage,
          status: event.status,
          timestamp: event.timestamp,
          duration: event.duration,
        );
    }
  }

  PrecedentSuggested _mapSuggestion(PrecedenteSugerido dto, int peticaoId) {
    final precedent = dto.toEntity();
    return PrecedentSuggested(
      id: 0,
      entityId: peticaoId,
      precedentId: dto.id,
      percentualSimilaridade: dto.similaridade,
      classificacao: dto.classificacao,
      sinteseExplicativa: dto.justificativa,
      precedent: precedent,
    );
  }
}
