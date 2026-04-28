import '../../../../core/utils/date_formater.dart';
import '../../../../core/utils/text_formater.dart';
import 'precedent.dart';
import '../utils/pangea_bnp_url_builder.dart';

class PrecedentSuggested {
  final int id;
  final int petitionId;
  final int precedentId;
  final double percentualSimilaridade;
  final int classificacao;
  final String? sinteseExplicativa;
  final Precedent? precedent;

  PrecedentSuggested({
    required this.id,
    required this.petitionId,
    required this.precedentId,
    required this.percentualSimilaridade,
    required this.classificacao,
    required this.sinteseExplicativa,
    this.precedent,
  });

  bool get hasSinteseExplicativa {
    return sinteseExplicativa?.trim().isNotEmpty ?? false;
  }

  String _getNumeroRegistro(String numeroRegistro) {
    final numeroRegistroSplit = numeroRegistro.trim().split('-').last;
    return numeroRegistroSplit;
  }

  String get titulo {
    return precedent?.especieNome ?? 'Espécie desconhecida';
  }

  String get title {
    final especieNome = precedent?.especieNome ?? 'Espécie desconhecida';
    final numeroRegistro = _getNumeroRegistro(precedent?.numeroRegistro ?? '');
    return '$especieNome n° $numeroRegistro';
  }

  String get tribunalSigla {
    return precedent?.tribunalSigla ?? 'Tribunal desconhecido';
  }

  String? get pangeaUrl {
    return PangeaBnpUrlBuilder.build(
      orgaoSigla: precedent?.tribunalSigla,
      especieNome: precedent?.especieNome,
      especieSigla: precedent?.especieSigla,
      numeroRegistro: precedent?.numeroRegistro,
    );
  }

  String get status {
    return precedent?.statusNome ?? 'Status desconhecido';
  }

  String get dataAtualizacao {
    final date = precedent?.ultimaAtualizacao;
    if (date == null) return '20/01/2020';
    return dateToLocalString(date);
  }

  String get thesis {
    final tese = precedent?.tese;
    return removeHtmlTags(tese ?? 'Sem tese disponivel.');
  }

  String get classificationLabel {
    switch (classificacao) {
      case 2:
        return 'Talvez Aplicável';
      case 1:
        return 'Aplicável';
      case 0:
        return 'Não Aplicável';
      default:
        return 'Não Aplicável';
    }
  }

  String get percentualSimilaridadePercentage {
    return '${percentualSimilaridade.toStringAsFixed(2)}%';
  }

  String get sinteseExplicativaText {
    return sinteseExplicativa ?? 'Sem síntese explicativa disponível.';
  }
}
