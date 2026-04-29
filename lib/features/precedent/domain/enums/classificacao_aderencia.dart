import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum ClassificacaoAderencia {
  naoAplicavel(0),
  possivelmenteAplicavel(1),
  aplicavel(2);

  final int value;
  const ClassificacaoAderencia(this.value);

  String get name {
    switch (this) {
      case ClassificacaoAderencia.aplicavel:
        return 'Aplicável';
      case ClassificacaoAderencia.possivelmenteAplicavel:
        return 'Possivelmente Aplicável';
      case ClassificacaoAderencia.naoAplicavel:
        return 'Não Aplicável';
    }
  }

  Color get color {
    switch (this) {
      case ClassificacaoAderencia.aplicavel:
        return AppColors.green600;
      case ClassificacaoAderencia.possivelmenteAplicavel:
        return AppColors.yellow600;
      case ClassificacaoAderencia.naoAplicavel:
        return AppColors.red600;
    }
  }
}
