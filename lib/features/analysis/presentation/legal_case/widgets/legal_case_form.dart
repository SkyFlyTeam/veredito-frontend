import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cookiecutter/core/theme/app_colors.dart';
import 'package:flutter_cookiecutter/shared/widgets/app_button.dart';
import 'package:flutter_cookiecutter/shared/widgets/app_select.dart';
import 'package:flutter_cookiecutter/shared/widgets/file_input.dart';
import 'package:flutter_cookiecutter/shared/widgets/glass_card.dart';
import 'package:flutter_cookiecutter/shared/widgets/message_box.dart';
import '../providers/legal_case_home_provider.dart';
import '../providers/tribunais_provider.dart';
import '../providers/uf_provider.dart';

class LegalCaseFormCard extends ConsumerWidget {
  const LegalCaseFormCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(legalCaseHomeProvider);
    final notifier = ref.read(legalCaseHomeProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final showErrors = state.showValidationErrors;

    return GlassCard(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados do Caso',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context: context,
              label: 'Área do Direito',
              onChanged: notifier.setAreaDireito,
              hasError: showErrors && !state.areaDireitoValid,
              errorText: 'Campo obrigatório',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              label: 'Pedidos Principais',
              onChanged: notifier.setPedidosPrincipais,
              hasError: showErrors && !state.pedidosValid,
              errorText: 'Campo obrigatório',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              label: 'Tese Pretendida',
              onChanged: notifier.setTesePretendida,
              hasError: showErrors && !state.teseValid,
              errorText: 'Campo obrigatório',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              label: 'Fatos Estruturados',
              onChanged: notifier.setFatosEstruturados,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              context: context,
              label: 'Fundamentos Jurídicos',
              onChanged: notifier.setFundamentosJuridicos,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TribunalSelect(onSelected: notifier.setTribunal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _UfSelect(
                    showError: showErrors && !state.ufValid,
                    onSelected: notifier.setUf,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Anexar Documentos',
              style: textTheme.bodySmall?.copyWith(
                color: showErrors && !state.filesValid
                    ? AppColors.red300
                    : AppColors.purple100,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            FileInput(
              acceptedExtensions: const ['pdf', 'docx', 'txt'],
              multiple: true,
              onUpload: (List<PlatformFile> files) {
                notifier.setFiles(
                  files.length > 3 ? files.take(3).toList() : files,
                );
              },
              onDelete: (_) => notifier.setFiles([]),
            ),
            if (showErrors && !state.filesValid) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  state.files.isEmpty
                      ? 'Envie ao menos 1 documento'
                      : 'Máximo de 3 documentos permitidos',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.red300,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (state.error != null) ...[
              MessageBox(
                message: state.error!,
                variant: MessageBoxVariant.error,
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Enviar',
                isLoading: state.isLoading,
                onPressed: state.isLoading ? null : notifier.submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required ValueChanged<String> onChanged,
    bool hasError = false,
    String? errorText,
    int maxLines = 1,
  }) {
    return TextField(
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: maxLines > 1 ? 2 : 1,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: hasError ? AppColors.red300 : AppColors.purple100,
        ),
        errorText: hasError ? errorText : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? AppColors.red300 : AppColors.gray300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? AppColors.red300 : AppColors.purple200,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red300),
        ),
      ),
    );
  }
}

class _UfSelect extends ConsumerWidget {
  final bool showError;
  final ValueChanged<String> onSelected;

  const _UfSelect({required this.showError, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ufAsync = ref.watch(ufProvider);

    return ufAsync.when(
      loading: () => const Center(
        child: SizedBox(
          height: 48,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const MessageBox(
        message: 'Erro ao carregar estados. Tente novamente.',
        variant: MessageBoxVariant.error,
      ),
      data: (ufs) => AppSelect<String>(
        label: 'UF',
        icon: Icons.location_on_outlined,
        expandedInsets: EdgeInsets.zero,
        showError: showError,
        errorMessage: showError ? 'Campo obrigatório' : null,
        entries: ufs
            .map((uf) => DropdownMenuEntry<String>(value: uf, label: uf))
            .toList(),
        onSelected: (value) {
          if (value != null) onSelected(value);
        },
      ),
    );
  }
}

class _TribunalSelect extends ConsumerWidget {
  final ValueChanged<int?> onSelected;

  const _TribunalSelect({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tribunaisAsync = ref.watch(tribunaisProvider);

    return tribunaisAsync.when(
      loading: () => const Center(
        child: SizedBox(
          height: 48,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const MessageBox(
        message: 'Erro ao carregar tribunais.',
        variant: MessageBoxVariant.error,
      ),
      data: (tribunais) => AppSelect<int>(
        label: 'Tribunal',
        icon: Icons.account_balance_outlined,
        expandedInsets: EdgeInsets.zero,
        entries: tribunais
            .map((t) => DropdownMenuEntry<int>(value: t.id, label: t.sigla))
            .toList(),
        onSelected: onSelected,
      ),
    );
  }
}
