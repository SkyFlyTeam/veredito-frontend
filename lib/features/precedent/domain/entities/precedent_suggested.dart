import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formater.dart';
import '../../../../core/utils/text_formater.dart';
import '../enums/classificacao_aderencia.dart';
import 'precedent.dart';
import '../utils/pangea_bnp_url_builder.dart';

class PrecedentSuggested {
  final int id;
  final int petitionId;
  final int precedentId;
  final double percentualSimilaridade;
  final int? classificacao;
  final String? sinteseExplicativa;
  final Precedent? precedent;

  PrecedentSuggested({
    required this.id,
    required this.petitionId,
    required this.precedentId,
    required this.percentualSimilaridade,
    this.classificacao,
    this.sinteseExplicativa,
    this.precedent,
  });

  bool get hasSinteseExplicativa {
    return sinteseExplicativa?.trim().isNotEmpty ?? false;
  }

  String _getNumeroRegistro(String numeroRegistro) {
    final numeroRegistroSplit = numeroRegistro.trim().split('-').last;
    return numeroRegistroSplit;
  }

  String get title {
    final especieNome = precedent?.especieNome ?? 'Espécie desconhecida';
    final numeroRegistro = _getNumeroRegistro(precedent?.numeroRegistro ?? '');
    return '$especieNome N° $numeroRegistro';
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

  ClassificacaoAderencia? get classificationEnum {
    if (classificacao == null) return null;
    try {
      return ClassificacaoAderencia.values
          .firstWhere((e) => e.value == classificacao);
    } catch (_) {
      return ClassificacaoAderencia.naoAplicavel;
    }
  }

  String get classificationLabel {
    return classificationEnum?.name ?? 'Não Aplicável';
  }

  Color get classificationColor {
    return classificationEnum?.color ?? AppColors.red600;
  }

  String get percentualSimilaridadePercentage {
    return '${percentualSimilaridade.toStringAsFixed(2)}%';
  }

  String get sinteseExplicativaText {
    return sinteseExplicativa ?? 'Sem síntese explicativa disponível.';
  }
}
