import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cookiecutter/core/network/api_client_provider.dart';
import '../../../data/data_sources/legal_case_remote_data_source.dart';
import '../../../data/repositories/legal_case_repository_impl.dart';
import '../../../domain/use_cases/create_legal_case_use_case.dart';
import '../view_models/legal_case_home_state.dart';
import '../view_models/legal_case_home_view_model.dart';

final legalCaseHomeProvider =
    StateNotifierProvider.autoDispose<LegalCaseHomeViewModel, LegalCaseHomeState>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final dataSource = LegalCaseRemoteDataSource(apiClient.dio);
  final repository = LegalCaseRepositoryImpl(dataSource);
  final usecase = CreateLegalCaseUsecase(repository);
  return LegalCaseHomeViewModel(usecase);
});