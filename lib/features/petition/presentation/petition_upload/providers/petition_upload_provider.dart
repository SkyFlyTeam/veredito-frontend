import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_cookiecutter/core/network/api_client_provider.dart';
import 'package:flutter_cookiecutter/features/petition/data/data_sources/petition_remote_data_source.dart';
import 'package:flutter_cookiecutter/features/petition/data/repositories/petition_repository_impl.dart';
import 'package:flutter_cookiecutter/features/petition/domain/use_cases/upload_petition_usecase.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/petition_upload/view_models/petition_upload_state.dart';
import 'package:flutter_cookiecutter/features/petition/presentation/petition_upload/view_models/petition_upload_view_model.dart';

final petitionUploadProvider =
    StateNotifierProvider<PetitionUploadViewModel, PetitionUploadState>((ref) {
      final apiClient = ref.read(apiClientProvider);
      final dataSource = PetitionRemoteDataSource(apiClient.dio);
      final repository = PetitionRepositoryImpl(dataSource);
      final usecase = UploadPetitionUsecase(repository);
      return PetitionUploadViewModel(usecase);
    });
