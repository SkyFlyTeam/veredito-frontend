import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final bool isLoading;
  final bool showError;

  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
  );

  const PasswordInput({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
    this.isLoading = false,
    this.showError = false,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscurePassword = true;

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatório';
    }
    if (!PasswordInput._passwordRegex.hasMatch(value)) {
      return 'A senha deve ter pelo menos 8 caracteres, incluir uma letra maiúscula, um número e um caractere especial.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text("Senha", style: Theme.of(context).textTheme.bodyMedium),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscurePassword,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: _defaultValidator,
          enabled: !widget.isLoading,
          decoration: InputDecoration(
            hintText: "************",
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: widget.showError ? AppColors.red300 : null,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: widget.isLoading
                      ? null
                      : () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: widget.showError ? AppColors.red300 : null,
                  ),
                ),
                if (widget.showError)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.red300,
                    ),
                  ),
              ],
            ),
            enabledBorder: widget.showError ? Theme.of(context).inputDecorationTheme.errorBorder : null,
            focusedBorder: widget.showError ? Theme.of(context).inputDecorationTheme.errorBorder : null,
          ),
        ),
      ],
    );
  }
}
