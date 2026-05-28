import '../precedent_suggested.dart';
import 'precedent_stream_pipeline.dart';

class SearchEvent extends PrecedentStreamPipelineEvent {
  final List<PrecedentSuggested> precedents;
  final int totalFound;
  final double averageSimilarityScore;

  SearchEvent({
    required super.stage,
    required super.status,
    required super.timestamp,
    required super.duration,
    required this.precedents,
    required this.totalFound,
    required this.averageSimilarityScore,
  });
}
