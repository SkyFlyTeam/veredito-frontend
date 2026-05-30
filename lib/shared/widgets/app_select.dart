import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppSelect<T> extends StatelessWidget {
  static const int _searchThreshold = 20;
  static const double _maxMenuHeight = 320;

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
    final bool enableSearch = entries.length > _searchThreshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: textTheme.bodyMedium?.copyWith(
              color: showError ? AppColors.red300 : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownMenu<T>(
          enabled: enabled,
          enableSearch: enableSearch,
          enableFilter: enableSearch,
          searchCallback: (List<DropdownMenuEntry<T>> entries, String query) {
            if (query.isEmpty) {
              return null;
            }

            final String normalizedQuery = query.toLowerCase();
            final int index = entries.indexWhere(
              (DropdownMenuEntry<T> entry) =>
                  entry.label.toLowerCase().contains(normalizedQuery),
            );

            return index != -1 ? index : null;
          },
          initialSelection: initialSelection,
          controller: controller,
          onSelected: onSelected,
          dropdownMenuEntries: entries,
          leadingIcon: icon != null
              ? Icon(icon, color: showError ? AppColors.red300 : Colors.white)
              : null,
          hintText: hintText,
          width: width,
          expandedInsets: expandedInsets,
          textStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
          menuHeight: enableSearch ? _maxMenuHeight : null,
          inputDecorationTheme: showError
              ? InputDecorationTheme(
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.red300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.red300),
                  ),
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  floatingLabelStyle: textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                )
              : InputDecorationTheme(
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
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
