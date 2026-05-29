import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/use_cases/create_legal_case_use_case.dart';
import 'legal_case_home_state.dart';

class LegalCaseHomeViewModel extends StateNotifier<LegalCaseHomeState> {
  final CreateLegalCaseUsecase _createUsecase;

  LegalCaseHomeViewModel(this._createUsecase)
    : super(const LegalCaseHomeState());

  void setAreaDireito(String value) =>
      state = state.copyWith(areaDireito: value);
  void setPedidosPrincipais(String value) =>
      state = state.copyWith(pedidosPrincipais: value);
  void setTesePretendida(String value) =>
      state = state.copyWith(tesePretendida: value);
  void setFatosEstruturados(String value) =>
      state = state.copyWith(fatosEstruturados: value);
  void setFundamentosJuridicos(String value) =>
      state = state.copyWith(fundamentosJuridicos: value);
  void setUf(String value) => state = state.copyWith(uf: value);
  void setTribunal(int? id) {
    if (id == null) {
      state = state.copyWith(clearTribunal: true);
    } else {
      state = state.copyWith(tribunalPrecedenteId: id);
    }
  }

  void setFiles(List<PlatformFile> files) =>
      state = state.copyWith(files: files);
  void reset() => state = const LegalCaseHomeState();

  Future<void> submit() async {
    if (!state.isFormValid) {
      state = state.copyWith(showValidationErrors: true);
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      isSuccess: false,
      showValidationErrors: false,
    );

    try {
      final files = state.files
          .map((f) => {'name': f.name, 'bytes': f.bytes!.toList()})
          .toList();

      final legalCase = await _createUsecase.execute(
        areaDireito: state.areaDireito.trim(),
        pedidosPrincipais: state.pedidosPrincipais.trim(),
        tesePretendida: state.tesePretendida.trim(),
        fatosEstruturados: state.fatosEstruturados.trim(),
        fundamentosJuridicos: state.fundamentosJuridicos.trim(),
        uf: state.uf.trim(),
        tribunalPrecedenteId: state.tribunalPrecedenteId,
        files: files,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        createdCase: legalCase,
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ??
          'Erro ao criar o caso jurídico. Tente novamente.';
      state = state.copyWith(isLoading: false, error: message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado. Tente novamente.',
      );
    }
  }
}
