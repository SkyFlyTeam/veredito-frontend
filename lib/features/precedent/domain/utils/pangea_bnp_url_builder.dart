class PangeaBnpUrlBuilder {
  PangeaBnpUrlBuilder._();

  static const _baseHost = 'pangeabnp.pdpj.jus.br';
  static const _basePath = '/pesquisa';

  static const _tipoMap = <String, String>{
    'repercussao geral': 'RG',
    'repercussão geral': 'RG',
    'sumula vinculante': 'SV',
    'súmula vinculante': 'SV',
    'acao direta de inconstitucionalidade': 'ADI',
    'ação direta de inconstitucionalidade': 'ADI',
    'acao declaratoria de constitucionalidade': 'ADC',
    'ação declaratória de constitucionalidade': 'ADC',
    'acao direta de inconstitucionalidade por omissao': 'ADO',
    'ação direta de inconstitucionalidade por omissão': 'ADO',
    'arguicao de descumprimento de preceito fundamental': 'ADPF',
    'arguição de descumprimento de preceito fundamental': 'ADPF',
    'recurso especial repetitivo': 'RESPR',
    'incidente de assuncao de competencia': 'IAC',
    'incidente de assunção de competência': 'IAC',
    'pedido de uniformizacao de interpretacao de lei': 'PUIL',
    'pedido de uniformização de interpretação de lei': 'PUIL',
    'controversia': 'CT',
    'controvérsia': 'CT',
    'recurso de revista repetitivo': 'IRR',
    'incidente de recursos repetitivos': 'IRR',
    'orientacao jurisprudencial': 'OJ',
    'orientação jurisprudencial': 'OJ',
    'precedente normativo': 'PN',
    'incidente de resolucao de demandas repetitivas': 'IRDR',
    'incidente de resolução de demandas repetitivas': 'IRDR',
    'suspensao nacional de irdr': 'SIRDR',
    'suspensão nacional de irdr': 'SIRDR',
    'grupo de representativos': 'GR',
    'representativo da controversia': 'Repr',
    'representativo da controvérsia': 'Repr',
    'sumula': 'SUM',
    'súmula': 'SUM',
    'nota tecnica': 'NT',
    'nota técnica': 'NT',
    'tema de repercussao geral': 'RG',
    'tema de repercussão geral': 'RG',
  };

  static final _numeroRegex = RegExp(r'(\d+)(?!.*\d)');

  static String? build({
    required String? orgaoSigla,
    required String? especieNome,
    required String? especieSigla,
    required String? numeroRegistro,
  }) {
    final normalizedOrgao = orgaoSigla?.trim().toLowerCase();
    final tipo = _extractTipo(especieNome: especieNome, especieSigla: especieSigla);
    final numero = _extractNumero(numeroRegistro);

    if (normalizedOrgao == null || normalizedOrgao.isEmpty) return null;
    if (tipo == null || numero == null) return null;

    return Uri(
      scheme: 'https',
      host: _baseHost,
      path: _basePath,
      queryParameters: {
        'orgao': normalizedOrgao,
        'tipo': tipo,
        'nr': numero,
      },
    ).toString();
  }

  static String? _extractTipo({
    required String? especieNome,
    required String? especieSigla,
  }) {
    final normalizedNome = especieNome?.trim().toLowerCase();
    if (normalizedNome != null && normalizedNome.isNotEmpty) {
      final sortedKeys = _tipoMap.keys.toList()
        ..sort((a, b) => b.length.compareTo(a.length));

      for (final key in sortedKeys) {
        if (normalizedNome.contains(key)) {
          return _tipoMap[key];
        }
      }
    }

    final normalizedSigla = especieSigla?.trim().toUpperCase();
    if (normalizedSigla != null && normalizedSigla.isNotEmpty) {
      return normalizedSigla;
    }

    return null;
  }

  static String? _extractNumero(String? numeroRegistro) {
    final normalized = numeroRegistro?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    final lastSegment = normalized.split('-').last.trim();
    if (lastSegment.isNotEmpty && int.tryParse(lastSegment) != null) {
      return lastSegment;
    }

    final match = _numeroRegex.firstMatch(normalized);
    return match?.group(1);
  }
}
