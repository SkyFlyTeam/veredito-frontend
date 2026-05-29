import 'package:file_picker/file_picker.dart';
import '../../../domain/entities/legal_case.dart';

class LegalCaseHomeState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final LegalCase? createdCase;
  final String areaDireito;
  final String pedidosPrincipais;
  final String tesePretendida;
  final String fatosEstruturados;
  final String fundamentosJuridicos;
  final String uf;
  final int? tribunalPrecedenteId;
  final List<PlatformFile> files;
  final bool showValidationErrors;

  const LegalCaseHomeState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.createdCase,
    this.areaDireito = '',
    this.pedidosPrincipais = '',
    this.tesePretendida = '',
    this.fatosEstruturados = '',
    this.fundamentosJuridicos = '',
    this.uf = '',
    this.tribunalPrecedenteId,
    this.files = const [],
    this.showValidationErrors = false,
  });

  bool get areaDireitoValid => areaDireito.trim().isNotEmpty;
  bool get pedidosValid => pedidosPrincipais.trim().isNotEmpty;
  bool get teseValid => tesePretendida.trim().isNotEmpty;
  bool get ufValid => uf.trim().isNotEmpty;
  bool get filesValid => files.isNotEmpty && files.length <= 3;
  bool get isFormValid =>
      areaDireitoValid && pedidosValid && teseValid && ufValid && filesValid;

  LegalCaseHomeState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isSuccess,
    LegalCase? createdCase,
    String? areaDireito,
    String? pedidosPrincipais,
    String? tesePretendida,
    String? fatosEstruturados,
    String? fundamentosJuridicos,
    String? uf,
    int? tribunalPrecedenteId,
    bool clearTribunal = false,
    List<PlatformFile>? files,
    bool? showValidationErrors,
  }) {
    return LegalCaseHomeState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
      createdCase: createdCase ?? this.createdCase,
      areaDireito: areaDireito ?? this.areaDireito,
      pedidosPrincipais: pedidosPrincipais ?? this.pedidosPrincipais,
      tesePretendida: tesePretendida ?? this.tesePretendida,
      fatosEstruturados: fatosEstruturados ?? this.fatosEstruturados,
      fundamentosJuridicos: fundamentosJuridicos ?? this.fundamentosJuridicos,
      uf: uf ?? this.uf,
      tribunalPrecedenteId: clearTribunal
          ? null
          : (tribunalPrecedenteId ?? this.tribunalPrecedenteId),
      files: files ?? this.files,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
    );
  }
}
