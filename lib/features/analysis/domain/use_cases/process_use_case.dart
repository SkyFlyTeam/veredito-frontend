import 'dart:io';

import '../entities/processo_juridico.dart';
import '../entities/tribunal_precedente.dart';
import '../repositories/process_repository.dart';

class ProcessUseCase {
  final ProcessRepository repository;

  ProcessUseCase({required this.repository});

  Future<ProcessoJuridico> createProcessoJuridico(
    File file,
    String areaDireito,
    String classeProcessual,
    TribunalPrecedente tribunal,
    int instancia,
  ) async {
    return repository.createProcessoJuridico(
      file: file,
      instancia: instancia,
      classeProcessual: classeProcessual,
      areaDireito: areaDireito,
      tribunalPrecedenteId: tribunal.id,
    );
  }
}