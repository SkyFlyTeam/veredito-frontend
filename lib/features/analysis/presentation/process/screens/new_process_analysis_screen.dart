import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/especie_precedente.dart';
import '../../../domain/entities/tribunal_precedente.dart';
import '../../shared/widgets/filter_bottom_sheet/filters_bottom_sheet.dart';

class NewProcessAnalysisScreen extends ConsumerStatefulWidget {

  const NewProcessAnalysisScreen({super.key});

  @override
  ConsumerState<NewProcessAnalysisScreen> createState() => _NewProcessAnalysisScreenState();
}

class _NewProcessAnalysisScreenState extends ConsumerState<NewProcessAnalysisScreen> {
  List<EspeciePrecedente> _selectedEspeciesPrecedentes = const [];
  List<TribunalPrecedente> _selectedTribunaisPrecedentes = const [];

  void _handleApply({
    required List<TribunalPrecedente> tribunais,
    required List<EspeciePrecedente> especies,
  }) {
    setState(() {
      _selectedTribunaisPrecedentes = tribunais;
      _selectedEspeciesPrecedentes = especies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Análise de Processo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tribunais selecionados: ${_selectedTribunaisPrecedentes.map((t) => t.sigla).join(', ')}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Espécies selecionadas: ${_selectedEspeciesPrecedentes.map((e) => e.sigla).join(', ')}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FloatingActionButton(
              onPressed: () => FiltersBottomSheet.show(
                context,
                onApply: _handleApply,
                initialTribunais: _selectedTribunaisPrecedentes,
                initialEspecies: _selectedEspeciesPrecedentes,
              ),
              child: const Icon(Icons.filter_list_rounded),
            ),
          ],
        ),
      ),
    );
  }
}