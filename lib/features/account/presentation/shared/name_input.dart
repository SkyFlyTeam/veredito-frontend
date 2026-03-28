import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NameInput extends StatefulWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final bool isLoading;
  final bool showError;

  const NameInput({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.isLoading = false,
    this.showError = false,
  });

  @override
  State<NameInput> createState() => _NameInputState();
}

class _NameInputState extends State<NameInput> {

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().split(' ').length < 2) {
      return 'Por favor, insira nome e um sobrenome';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text("Nome Completo", style: Theme.of(context).textTheme.bodyMedium),
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.name,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: _defaultValidator,
          enabled: !widget.isLoading,
          decoration: InputDecoration(
            hintText: 'John Doe',
            prefixIcon: Icon(
              Icons.person_rounded,
              color: widget.showError ? AppColors.red300 : null,
            ),
            suffixIcon: widget.showError
                ? const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.red300,
                  )
                : null,
            enabledBorder: widget.showError ? Theme.of(context).inputDecorationTheme.errorBorder : null,
            focusedBorder: widget.showError ? Theme.of(context).inputDecorationTheme.errorBorder : null,
          ),
        ),
      ],
    );
  }
}
