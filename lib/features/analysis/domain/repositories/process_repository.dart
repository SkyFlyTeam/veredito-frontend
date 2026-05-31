import 'dart:io';

import '../entities/processo_juridico.dart';

abstract class ProcessRepository {
  Future<ProcessoJuridico> createProcessoJuridico({
    required File file,
    required int instancia,
    required String classeProcessual,
    required String areaDireito,
    required int tribunalPrecedenteId,
  });

  Future<List<int>> generateMinutaSentenca({
    required int processoId,
    required String dispositivo,
    required List<int> precedentesSugeridos,
  });
}