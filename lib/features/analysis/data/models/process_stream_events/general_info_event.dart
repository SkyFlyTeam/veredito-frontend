import '../precedent_stream_events/precedent_stream_pipeline_event.dart';

class GeneralInfoEvent extends StreamPipelineEvent {
  final String fatos;
  final String fundamentosJuridicos;
  final String pedidos;

  GeneralInfoEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required super.data,
    required this.fatos,
    required this.fundamentosJuridicos,
    required this.pedidos,
  });

  factory GeneralInfoEvent.fromJson(Map<String, dynamic> json) {
    final eventData = json['data'] as Map<String, dynamic>;
    final information = eventData['information'] as Map<String, dynamic>;

    return GeneralInfoEvent(
      stage: json['stage'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      duration: json['duration'] as int,
      data: eventData,
      fatos: (information['fatos'] as String?) ?? '',
      fundamentosJuridicos: (information['fundamentosJuridicos'] as String?) ?? '',
      pedidos: (information['pedidos'] as String?) ?? '',
    );
  }
}