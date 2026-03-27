import 'package:flutter/material.dart';

import '../../../domain/entities/precedent.dart';
import '../../../domain/entities/precedent_suggested.dart';
import '../widget/PrecedentSuggestedCard.dart';

class PrecedentSuggestedTestScreen extends StatelessWidget {
  const PrecedentSuggestedTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <PrecedentSuggested>[
      PrecedentSuggested(
        id: 1,
        petitionId: 1,
        precedentId: 387,
        percentualSimilaridade: 70,
        classificacao: 2,
        sinteseExplicativa:
            'Ambas teses tratam sobre os novos procedimentos estéticos que causam dano moral e legal.',
        precedent: Precedent(
          id: 387,
          numeroRegistro: '387',
          tese: 'É lícita a cumulação das indenizações de dano estético e dano moral.',
          ultimaAtualizacao: DateTime(2026, 3, 25),
          teseVetor: null,
          questaoVetor: null,
          tribunalNome: 'Superior Tribunal de Justiça',
          tribunalSigla: 'STJ',
        ),
      ),
      PrecedentSuggested(
        id: 2,
        petitionId: 1,
        precedentId: 388,
        percentualSimilaridade: null,
        classificacao: null,
        sinteseExplicativa: null,
        precedent: Precedent(
          id: 388,
          numeroRegistro: '388',
          tese: 'É lícita a cumulação das indenizações de dano estético e dano moral.',
          ultimaAtualizacao: DateTime(2026, 3, 25),
          teseVetor: null,
          questaoVetor: null,
          tribunalNome: 'Superior Tribunal de Justiça',
          tribunalSigla: 'STJ',
        ),
      ),
      PrecedentSuggested(
        id: 3,
        petitionId: 1,
        precedentId: 389,
        percentualSimilaridade: null,
        classificacao: null,
        sinteseExplicativa: 
            'Ambas teses tratam sobre os novos procedimentos estéticos que causam dano moral e legal.',
        precedent: Precedent(
          id: 389,
          numeroRegistro: '389 ',
          tese: 'É lícita a cumulação das indenizações de dano estético e dano moral.',
          ultimaAtualizacao: DateTime(2026, 3, 26),
          teseVetor: null,
          questaoVetor: null,
          tribunalNome: 'Superior Tribunal de Justiça',
          tribunalSigla: 'STJ',
        ),
      ),
      PrecedentSuggested(
        id: 4,
        petitionId: 1,
        precedentId: 390,
        percentualSimilaridade: 90,
        classificacao: 1,
        sinteseExplicativa: null,
        precedent: Precedent(
          id: 390,
          numeroRegistro: '390',
          tese: 'É lícita a cumulação das indenizações de dano estético e dano moral.',
          ultimaAtualizacao: DateTime(2026, 3, 26),
          teseVetor: null,
          questaoVetor: null,
          tribunalNome: 'Superior Tribunal de Justiça',
          tribunalSigla: 'STJ',
        ),
      ),
      PrecedentSuggested(
        id: 5,
        petitionId: 1,
        precedentId: 391,
        percentualSimilaridade: 40,
        classificacao: 0,
        sinteseExplicativa: null,
        precedent: Precedent(
          id: 391,
          numeroRegistro: '391',
          tese: 'É lícita a cumulação das indenizações de dano estético e dano moral.',
          ultimaAtualizacao: DateTime(2026, 3, 26),
          teseVetor: null,
          questaoVetor: null,
          tribunalNome: 'Superior Tribunal de Justiça',
          tribunalSigla: 'STJ',
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF11121C),
      appBar: AppBar(
        title: const Text('Teste - Petições Sugeridas'),
        backgroundColor: const Color(0xFF11121C),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return PrecedentSuggestedCard(suggestion: item);
        },
      ),
    );
  }
}
