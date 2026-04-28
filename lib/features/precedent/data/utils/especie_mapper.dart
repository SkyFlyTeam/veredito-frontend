class EspecieMapper {
  static const Map<int, String> _nomes = {
    1: 'Súmula',
    2: 'Orientação Jurisprudencial',
    3: 'Incidente de Assunção de Competência',
    4: 'Incidente de Resolução de Demandas Repetitivas',
    5: 'Precedente Normativo',
    6: 'Incidente de Recurso Repetitivo',
    7: 'Súmula Vinculante',
    8: 'Suspensão Nacional em IRDR',
    9: 'Recurso Especial Repetitivo',
    10: 'Tema de Repercussão Geral',
    11: 'Controle Concentrado',
    12: 'Ação Direta de Inconstitucionalidade',
    13: 'Ação Declaratória de Constitucionalidade',
    14: 'ADI por Omissão',
    15: 'Arguição de Descumprimento de Preceito Fundamental',
    16: 'Pedido de Uniformização de Interpretação de Lei',
    17: 'Controvérsia',
    18: 'Nota Técnica',
    19: 'Nota de Adesão',
    20: 'Enunciado',
    21: 'Representativo da Controvérsia',
  };

  static const Map<int, String> _siglas = {
    1: 'SUM',
    2: 'OJ',
    3: 'IAC',
    4: 'IRDR',
    5: 'PN',
    6: 'IRR',
    7: 'SV',
    8: 'SIRDR',
    9: 'RR',
    10: 'RG',
    11: 'ADI ADC ADO ADPF',
    12: 'ADI',
    13: 'ADC',
    14: 'ADO',
    15: 'ADPF',
    16: 'PUIL',
    17: 'CT',
    18: 'NT',
    19: 'NTA',
    20: 'ENU',
    21: 'RC',
  };

  static String nome(int? especieId) =>
      _nomes[especieId] ?? 'Espécie desconhecida';

  static String sigla(int? especieId) =>
      _siglas[especieId] ?? '?';

  static String titulo(int? especieId, String numeroRegistro) {
    final sigla = _siglas[especieId];
    final numero = numeroRegistro.trim().split('-').last.toUpperCase();
    if (sigla == null) return 'Nº $numero';
    return '$sigla Nº $numero';
  }
}