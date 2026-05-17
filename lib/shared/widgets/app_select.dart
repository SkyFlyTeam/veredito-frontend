import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppSelect<T> extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final List<DropdownMenuEntry<T>> entries;
  final ValueChanged<T?>? onSelected;
  final T? initialSelection;
  final String? hintText;
  final bool enabled;
  final double? width;
  final EdgeInsetsGeometry? expandedInsets;
  final TextEditingController? controller;
  final bool showError;
  final String? errorMessage;

  const AppSelect({
    super.key,
    required this.entries,
    this.onSelected,
    this.label,
    this.icon,
    this.initialSelection,
    this.hintText,
    this.enabled = true,
    this.width,
    this.expandedInsets,
    this.controller,
    this.showError = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownMenu<T>(
          enabled: enabled,
          initialSelection: initialSelection,
          controller: controller,
          onSelected: onSelected,
          dropdownMenuEntries: entries,
          label: label != null ? Text(label!) : null,
          leadingIcon: icon != null
              ? Icon(
                  icon,
                  color: showError ? AppColors.red300 : null,
                )
              : null,
          hintText: hintText,
          width: width,
          expandedInsets: expandedInsets,
          inputDecorationTheme: showError
              ? InputDecorationTheme(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.red300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.red300),
                  ),
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: AppColors.red300,
                  ),
                  floatingLabelStyle: textTheme.bodyMedium?.copyWith(
                    color: AppColors.red300,
                  ),
                )
              : null,
          menuStyle: MenuStyle(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.gray200),
              ),
            ),
            backgroundColor: WidgetStateProperty.all(AppColors.blue900),
          ),
        ),
        if (showError && errorMessage != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorMessage!,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.red300,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
