import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_select.dart';
import '../../../../../shared/widgets/message_box.dart';
import '../../../domain/entities/especie_precedente.dart';
import '../../../domain/entities/tribunal_precedente.dart';
import '../../shared/widgets/filter_bottom_sheet/filters_bottom_sheet.dart';
import '../../../../../shared/widgets/file_input.dart';
import '../providers/new_process_analysis_providers.dart';

class NewProcessAnalysisScreen extends ConsumerStatefulWidget {
  const NewProcessAnalysisScreen({super.key});

  @override
  ConsumerState<NewProcessAnalysisScreen> createState() =>
      _NewProcessAnalysisScreenState();
}

class _NewProcessAnalysisScreenState
    extends ConsumerState<NewProcessAnalysisScreen> {
  List<EspeciePrecedente> _selectedEspeciesPrecedentes = const [];
  List<TribunalPrecedente> _selectedTribunaisPrecedentes = const [];
  final TextEditingController _areaDireitoController = TextEditingController();
  final TextEditingController _classeProcessualController =
      TextEditingController();

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
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(newProcessAnalysisViewModelProvider.notifier)
          .initialize(),
    );
  }

  @override
  void dispose() {
    _areaDireitoController.dispose();
    _classeProcessualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newProcessAnalysisViewModelProvider);
    final viewModel = ref.read(newProcessAnalysisViewModelProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.red300),
    );

    final showValidationErrors = state.showValidationErrors;
    final hasAreaError =
        showValidationErrors && state.areaDireito.trim().isEmpty;
    final hasClasseError =
        showValidationErrors && state.classeProcessual.trim().isEmpty;
    final hasTribunalError =
        showValidationErrors && state.selectedTribunal == null;
    final hasInstanciaError = showValidationErrors && state.instancia == null;
    final hasFileError = showValidationErrors && state.file == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Análise de Processo')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Arquivo',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              FileInput(
                acceptedExtensions: ['.pdf', '.docx', '.txt'],
                multiple: false,
                onUpload: (files) {
                  final file = files.first;
                  if (file.path == null) {
                    viewModel.setErrorMessage(
                      'Nao foi possivel carregar o arquivo selecionado.',
                    );
                    viewModel.setFile(null);
                    return;
                  }
                  viewModel.setFile(File(file.path!));
                },
                onDelete: (_) => viewModel.setFile(null),
              ),
              if (hasFileError) ...[
                const SizedBox(height: 10),
                Text(
                  'Preencha este campo.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.red300,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Contexto do Tribunal',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              if (state.errorMessage != null) ...[
                MessageBox(
                  message: state.errorMessage!,
                  variant: MessageBoxVariant.error,
                ),
                const SizedBox(height: 18),
              ],
              Text(
                'Area do Direito',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _areaDireitoController,
                textInputAction: TextInputAction.next,
                onChanged: viewModel.setAreaDireito,
                decoration: InputDecoration(
                  hintText: 'Ex: Direito Civil',
                  suffixIcon: hasAreaError
                      ? const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.red300,
                        )
                      : null,
                  enabledBorder: hasAreaError ? errorBorder : null,
                  focusedBorder: hasAreaError ? errorBorder : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Classe Processual',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _classeProcessualController,
                textInputAction: TextInputAction.next,
                onChanged: viewModel.setClasseProcessual,
                decoration: InputDecoration(
                  hintText: 'Ex: Apelacao',
                  suffixIcon: hasClasseError
                      ? const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.red300,
                        )
                      : null,
                  enabledBorder: hasClasseError ? errorBorder : null,
                  focusedBorder: hasClasseError ? errorBorder : null,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppSelect<TribunalPrecedente>(
                      label: 'Tribunal',
                      hintText: state.isLoadingTribunais
                          ? 'Carregando...'
                          : 'Selecione um tribunal',
                      enabled: !state.isLoadingTribunais,
                      entries: state.tribunais
                          .map(
                            (tribunal) => DropdownMenuEntry(
                              value: tribunal,
                              label: tribunal.sigla.trim().isNotEmpty
                                  ? tribunal.sigla
                                  : tribunal.nome,
                            ),
                          )
                          .toList(),
                      onSelected: viewModel.setTribunal,
                      showError: hasTribunalError,
                      errorMessage: 'Preencha este campo.',
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 140,
                    child: AppSelect<int>(
                      label: 'Instancia',
                      entries: const [
                        DropdownMenuEntry(value: 1, label: '1a'),
                        DropdownMenuEntry(value: 2, label: '2a'),
                      ],
                      onSelected: viewModel.setInstancia,
                      showError: hasInstanciaError,
                      errorMessage: 'Preencha este campo.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Analisar documento',
                onPressed: state.isSubmitting ? null : viewModel.submit,
                isLoading: state.isSubmitting,
                mainAxisSize: MainAxisSize.max,
              ),
              const SizedBox(height: 12),
              AppButton(
                onPressed: () => FiltersBottomSheet.show(
                  context,
                  onApply: _handleApply,
                  initialTribunais: _selectedTribunaisPrecedentes,
                  initialEspecies: _selectedEspeciesPrecedentes,
                ),
                label: 'Refinar Análise',
                mainAxisSize: MainAxisSize.max,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
