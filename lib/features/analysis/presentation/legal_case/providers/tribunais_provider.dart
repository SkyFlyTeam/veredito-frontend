import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cookiecutter/core/network/api_client_provider.dart';
import 'package:flutter_cookiecutter/features/analysis/data/data_sources/filters_remote_data_source.dart';
import 'package:flutter_cookiecutter/features/analysis/data/repositories/filters_repository_impl.dart';
import 'package:flutter_cookiecutter/features/analysis/domain/entities/tribunal_precedente.dart';

final tribunaisProvider = FutureProvider<List<TribunalPrecedente>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final dataSource = FiltersRemoteDataSource(dio: apiClient.dio);
  final repository = FiltersRepositoryImpl(dataSource);
  return repository.fetchTribunais();
});