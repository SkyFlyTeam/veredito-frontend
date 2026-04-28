class PipelineEvent {
  final String stage;
  final String status;
  final String timestamp;
  final int duration;
  final Map<String, dynamic> data;

  PipelineEvent({
    required this.stage,
    required this.status,
    required this.timestamp,
    required this.duration,
    required this.data,
  });

  factory PipelineEvent.fromJson(Map<String, dynamic> json) {
    final stage = json['stage'] as String;

    switch (stage) {
      case 'resumo':
        return ResumoEvent.fromJson(json);
      case 'search':
        return SearchEvent.fromJson(json);
      case 'synthesis':
        return SynthesisEvent.fromJson(json);
      case 'complete':
        return CompleteEvent.fromJson(json);
      case 'error':
        return ErrorEvent.fromJson(json);
      default:
        return PipelineEvent(
          stage: stage,
          status: json['status'] as String,
          timestamp: json['timestamp'] as String,
          duration: json['duration'] as int,
          data: json['data'] as Map<String, dynamic>,
        );
    }
  }
}

class PrecedentBackendDto {
  final int id;
  final String numero_registro;
  final String? tese;
  final String? questao;
  final int? tribunal_id;
  final int? especie_id;
  final int? status_id;
  final double score;

  PrecedentBackendDto({
    required this.id,
    required this.numero_registro,
    this.tese,
    this.questao,
    this.tribunal_id,
    this.especie_id,
    this.status_id,
    required this.score,
  });

  factory PrecedentBackendDto.fromJson(Map<String, dynamic> json) {
    return PrecedentBackendDto(
      id: json['id'] as int,
      numero_registro: (json['numero_registro'] as String?) ?? '',
      tese: json['tese'] as String?,
      questao: json['questao'] as String?,
      tribunal_id: json['tribunal_id'] as int?,
      especie_id: json['especie_id'] as int?,
      status_id: json['status_id'] as int?,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  double get percentualSimilaridade =>
      double.parse((((score + 1) / 2) * 100).toStringAsFixed(2));
}

class ResumoEvent extends PipelineEvent {
  final String resumo;

  ResumoEvent({
    required String stage,
    required String status,
    required String timestamp,
    required int duration,
    required Map<String, dynamic> data,
    required this.resumo,
  }) : super(
         stage: stage,
         status: status,
         timestamp: timestamp,
         duration: duration,
         data: data,
       );

  factory ResumoEvent.fromJson(Map<String, dynamic> json) {
    final eventData = json['data'] as Map<String, dynamic>;

    return ResumoEvent(
      stage: json['stage'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: eventData,
      resumo: (eventData['resumo'] as String?) ?? '',
    );
  }
}

class SearchEvent extends PipelineEvent {
  final List<PrecedentBackendDto> precedents;
  final int totalFound;
  final double averageSimilarityScore;

  SearchEvent({
    required String stage,
    required String status,
    required String timestamp,
    required int duration,
    required Map<String, dynamic> data,
    required this.precedents,
    required this.totalFound,
    required this.averageSimilarityScore,
  }) : super(
         stage: stage,
         status: status,
         timestamp: timestamp,
         duration: duration,
         data: data,
       );

  factory SearchEvent.fromJson(Map<String, dynamic> json) {
    final eventData = json['data'] as Map<String, dynamic>;
    final precedentsJson = eventData['precedents'] as List<dynamic>;

    return SearchEvent(
      stage: json['stage'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: eventData,
      precedents: precedentsJson
          .map((p) => PrecedentBackendDto.fromJson(p as Map<String, dynamic>))
          .toList(),
      totalFound: eventData['totalFound'] as int,
      averageSimilarityScore:
          (eventData['averageSimilarityScore'] as num).toDouble(),
    );
  }
}

class SynthesisEvent extends PipelineEvent {
  final int id;
  final int classificacao;
  final String sintese_explicativa;
  final int precedenteId;
  final int peticaoId;

  SynthesisEvent({
    required String stage,
    required String status,
    required String timestamp,
    required int duration,
    required Map<String, dynamic> data,
    required this.id,
    required this.classificacao,
    required this.sintese_explicativa,
    required this.precedenteId,
    required this.peticaoId,
  }) : super(
         stage: stage,
         status: status,
         timestamp: timestamp,
         duration: duration,
         data: data,
       );

  factory SynthesisEvent.fromJson(Map<String, dynamic> json) {
    final eventData = json['data'] as Map<String, dynamic>;

    return SynthesisEvent(
      stage: json['stage'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: eventData,
      id: eventData['id'] as int,
      classificacao: eventData['classificacao'] as int,
      sintese_explicativa:
          (eventData['sintese_explicativa'] as String?) ?? '',
      precedenteId: eventData['precedenteId'] as int,
      peticaoId: eventData['peticaoId'] as int,
    );
  }
}

class CompleteEvent extends PipelineEvent {
  final int totalDurationMs;
  final int precedentsProcessed;
  final int synthesisGenerated;

  CompleteEvent({
    required String stage,
    required String status,
    required String timestamp,
    required int duration,
    required Map<String, dynamic> data,
    required this.totalDurationMs,
    required this.precedentsProcessed,
    required this.synthesisGenerated,
  }) : super(
         stage: stage,
         status: status,
         timestamp: timestamp,
         duration: duration,
         data: data,
       );

  factory CompleteEvent.fromJson(Map<String, dynamic> json) {
    final eventData = json['data'] as Map<String, dynamic>;

    return CompleteEvent(
      stage: json['stage'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: eventData,
      totalDurationMs: eventData['totalDurationMs'] as int,
      precedentsProcessed: eventData['precedentsProcessed'] as int,
      synthesisGenerated: eventData['synthesisGenerated'] as int,
    );
  }
}

class ErrorEvent extends PipelineEvent {
  final String failedStage;
  final String message;
  final String errorCode;
  final int? precedentId;
  final bool recoverable;

  ErrorEvent({
    required String stage,
    required String status,
    required String timestamp,
    required int duration,
    required Map<String, dynamic> data,
    required this.failedStage,
    required this.message,
    required this.errorCode,
    this.precedentId,
    required this.recoverable,
  }) : super(
         stage: stage,
         status: status,
         timestamp: timestamp,
         duration: duration,
         data: data,
       );

  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    final eventData = json['data'] as Map<String, dynamic>;

    return ErrorEvent(
      stage: json['stage'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: eventData,
      failedStage: (eventData['failedStage'] as String?) ?? '',
      message: (eventData['message'] as String?) ?? '',
      errorCode: (eventData['errorCode'] as String?) ?? '',
      precedentId: eventData['precedentId'] as int?,
      recoverable: (eventData['recoverable'] as bool?) ?? false,
    );
  }
}