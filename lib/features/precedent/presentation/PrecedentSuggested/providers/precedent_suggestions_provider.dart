import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/precedent_remote_data_source.dart';
import '../../../data/repositories/precedent_repository_impl.dart';
import '../../../domain/entities/precedent_suggested.dart';
import '../../../domain/repositories/precedent_repository.dart';
import '../../../domain/use_cases/analyze_petition_usecase.dart';
import '../../../domain/use_cases/get_precedent_suggestions_usecase.dart';

final precedentRemoteDataSourceProvider = Provider<PrecedentRemoteDataSource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return PrecedentRemoteDataSource(apiClient.dio);
});

final precedentRepositoryProvider = Provider<PrecedentRepository>((ref) {
  final remoteDataSource = ref.read(precedentRemoteDataSourceProvider);
  return PrecedentRepositoryImpl(remoteDataSource);
});

final getPrecedentSuggestionsUsecaseProvider =
    Provider<GetPrecedentSuggestionsUsecase>((ref) {
      final repository = ref.read(precedentRepositoryProvider);
      return GetPrecedentSuggestionsUsecase(repository);
    });

final analyzePetitionUsecaseProvider = Provider<AnalyzePetitionUsecase>((ref) {
  final repository = ref.read(precedentRepositoryProvider);
  return AnalyzePetitionUsecase(repository);
});

final precedentSuggestionsProvider =
    FutureProvider.family<List<PrecedentSuggested>, int?>((ref, petitionId) {
      final usecase = ref.read(getPrecedentSuggestionsUsecaseProvider);
      return usecase.execute(petitionId: petitionId);
    });
