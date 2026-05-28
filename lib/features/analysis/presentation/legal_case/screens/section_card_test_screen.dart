import 'package:flutter/material.dart';

import '../../../../../features/analysis/domain/entities/secao_peticao.dart';
import '../widgets/section_card.dart';

/// Tela temporária de teste para visualização do [SectionCard].
/// Remover após integração com dados reais.
class SectionCardTestScreen extends StatefulWidget {
  const SectionCardTestScreen({super.key});

  @override
  State<SectionCardTestScreen> createState() => _SectionCardTestScreenState();
}

class _SectionCardTestScreenState extends State<SectionCardTestScreen> {
  final List<SecaoPeticao> _secoes = [
    SecaoPeticao(
      id: 1,
      titulo: 'Endereçamento',
      conteudo:
          'Excelentíssimo Senhor Doutor Juiz de Direito da _ª Vara Cível da Comarca de São Paulo.',
    ),
    SecaoPeticao(
      id: 2,
      titulo: 'Dos Fatos',
      conteudo:
          'O requerente, devidamente qualificado nos autos, vem, respeitosamente, à presença de Vossa Excelência, expor e requerer o que segue.\n\nNa data de 01/01/2025, o requerente celebrou contrato de prestação de serviços com a parte requerida, conforme documento anexo.',
    ),
    SecaoPeticao(
      id: 3,
      titulo: 'Dos Pedidos',
      conteudo:
          'Diante do exposto, requer a Vossa Excelência se digne a:\n\na) Deferir a tutela antecipada;\nb) Condenar a parte requerida ao pagamento da quantia de R\$ 10.000,00;\nc) Condenar a parte requerida ao pagamento das custas processuais e honorários advocatícios.',
    ),
  ];

  void _onEdit(SecaoPeticao secaoEditada) {
    setState(() {
      final index = _secoes.indexWhere((s) => s.id == secaoEditada.id);
      if (index != -1) {
        _secoes[index] = secaoEditada;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seções da Petição')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: _secoes
              .map(
                (secao) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SectionCard(
                    secao: secao,
                    onEdit: _onEdit,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
