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

  Future<List<int>> generateMinutaSentenca({
    required int processoId,
    required String dispositivo,
    required List<int> precedentesSugeridos,
  }) {
    return repository.generateMinutaSentenca(
      processoId: processoId,
      dispositivo: dispositivo,
      precedentesSugeridos: precedentesSugeridos,
    );
  }
}