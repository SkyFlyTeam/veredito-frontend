import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class EmailInput extends StatefulWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final bool isLoading;
  final bool showError;

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  const EmailInput({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.isLoading = false,
    this.showError = false,
  });

  @override
  State<EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    if (!EmailInput._emailRegex.hasMatch(value)) {
      return 'Por favor, insira um endereço de email válido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text("E-mail", style: Theme.of(context).textTheme.bodyMedium),
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.emailAddress,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: _defaultValidator,
          enabled: !widget.isLoading,
          decoration: InputDecoration(
            hintText: 'email@gmail.com',
            prefixIcon: Icon(
              Icons.alternate_email_rounded,
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
