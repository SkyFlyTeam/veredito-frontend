import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_client_provider.dart';
import '../../../data/data_sources/petition_remote_data_source.dart';
import '../../../data/repositories/petition_repository_impl.dart';
import '../../../domain/use_cases/upload_petition_usecase.dart';
import '../view_models/petition_upload_state.dart';
import '../view_models/petition_upload_view_model.dart';

final petitionUploadProvider =
    StateNotifierProvider<PetitionUploadViewModel, PetitionUploadState>((ref) {
      final apiClient = ref.read(apiClientProvider);
      final dataSource = PetitionRemoteDataSource(apiClient.dio);
      final repository = PetitionRepositoryImpl(dataSource);
      final usecase = UploadPetitionUsecase(repository);
      return PetitionUploadViewModel(usecase);
    });
