
import 'precedent_stream_pipeline_event.dart';
import '../precedente_sugerido.dart';

class SearchEvent extends StreamPipelineEvent {
  final List<PrecedenteSugerido> precedents;
  final int totalFound;
  final double averageSimilarityScore;

  SearchEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required super.data,
    required this.precedents,
    required this.totalFound,
    required this.averageSimilarityScore,
  });

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
          .map((p) => PrecedenteSugerido.fromJson(p as Map<String, dynamic>))
          .toList(),
      totalFound: eventData['totalFound'] as int,
      averageSimilarityScore: (eventData['averageSimilarityScore'] as num)
          .toDouble(),
    );
  }
}