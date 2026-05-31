

import '../../domain/entities/precedent_stream_events/complete_event.dart';
import '../../domain/entities/precedent_stream_events/error_event.dart';
import '../../domain/entities/precedent_stream_events/precedent_stream_pipeline.dart';
import '../../domain/entities/precedent_stream_events/search_event.dart';
import '../../domain/entities/precedent_stream_events/synthesis_event.dart';
import '../../domain/entities/precedent_suggested.dart';
import '../../domain/entities/process_stream_events/general_info_event.dart';
import '../../domain/entities/process_stream_events/pecas_event.dart';
import '../../domain/repositories/process_pipeline_repository.dart';
import '../data_sources/process_pipeline_remote_data_souce.dart';
import '../models/precedent_stream_events/complete_event.dart' as data_models;
import '../models/precedent_stream_events/error_event.dart' as data_models;
import '../models/precedent_stream_events/precedent_stream_pipeline_event.dart' as data_models;
import '../models/precedente_sugerido.dart';
import '../models/precedent_stream_events/search_event.dart' as data_models;
import '../models/precedent_stream_events/synthesis_event.dart' as data_models;
import '../models/process_stream_events/general_info_event.dart' as data_models;
import '../models/process_stream_events/pecas_event.dart' as data_models;

class ProcessPipelineRepositoryImpl implements ProcessPipelineRepository {
  final ProcessPipelineRemoteDataSource dataSource;

  ProcessPipelineRepositoryImpl(this.dataSource);

  @override
  Stream<PrecedentStreamPipelineEvent> streamPipeline(int processoId, List<int>? tribunaisIds, List<int>? especiesIds) {
    return dataSource
        .streamPipeline(processoId, tribunaisIds, especiesIds)
        .map((event) => _mapEvent(event, processoId));
  }

  @override
  void cancelStream(int processoId) {
    dataSource.cancelStream(processoId);
  }

  @override
  void cancelAll() {
    dataSource.cancelAll();
  }

  PrecedentStreamPipelineEvent _mapEvent(
    data_models.StreamPipelineEvent event,
    int processoId,
  ) {
    switch (event) {
      case data_models.GeneralInfoEvent generalInfoEvent:
        return GeneralInfoEvent(
          stage: generalInfoEvent.stage,
          status: generalInfoEvent.status,
          timestamp: generalInfoEvent.timestamp,
          duration: generalInfoEvent.duration,
          fatos: generalInfoEvent.fatos,
          fundamentosJuridicos: generalInfoEvent.fundamentosJuridicos,
          pedidos: generalInfoEvent.pedidos,
        );
      case data_models.PecasEvent pecasEvent:
        return PecasEvent(
          stage: pecasEvent.stage,
          status: pecasEvent.status,
          timestamp: pecasEvent.timestamp,
          duration: pecasEvent.duration,
          pecas: pecasEvent.pecas.map((dto) => dto.toEntity()).toList(),
        );
      case data_models.SearchEvent searchEvent:
        return SearchEvent(
          stage: searchEvent.stage,
          status: searchEvent.status,
          timestamp: searchEvent.timestamp,
          duration: searchEvent.duration,
          precedents: searchEvent.precedents
              .map((dto) => _mapSuggestion(dto, processoId))
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

  PrecedentSuggested _mapSuggestion(PrecedenteSugerido dto, int processoId) {
    final precedent = dto.toEntity();
    return PrecedentSuggested(
      id: 0,
      entityId: processoId,
      precedentId: dto.id,
      percentualSimilaridade: dto.similaridade,
      classificacao: dto.classificacao,
      sinteseExplicativa: dto.justificativa,
      precedent: precedent,
    );
  }
}
