import 'dart:io';

import '../../domain/entities/processo_juridico.dart';
import '../../domain/repositories/process_repository.dart';
import '../data_sources/process_remote_data_source.dart';

class ProcessRepositoryImpl implements ProcessRepository {
  final ProcessRemoteDataSource remoteDataSource;
  
  ProcessRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<ProcessoJuridico> createProcessoJuridico({
    required File file,
    required int instancia,
    required String classeProcessual,
    required String areaDireito,
    required int tribunalPrecedenteId,
  }) async {
    try {
      final result = await remoteDataSource.createProcessoJuridico(
        file: file,
        instancia: instancia,
        classeProcessual: classeProcessual,
        areaDireito: areaDireito,
        tribunalPrecedenteId: tribunalPrecedenteId,
      );

      return result.toEntity();
    } catch (e) {
      throw Exception('Failed to create processo juridico: $e');
    }
  }
}