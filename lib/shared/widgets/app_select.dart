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
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      enabled: enabled,
      initialSelection: initialSelection,
      controller: controller,
      onSelected: onSelected,
      dropdownMenuEntries: entries,
      label: label != null ? Text(label!) : null,
      leadingIcon: icon != null ? Icon(icon) : null,
      hintText: hintText,
      width: width,
      expandedInsets: expandedInsets,
      menuStyle: MenuStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.gray200),
          ),
        ),
        backgroundColor: WidgetStateProperty.all(AppColors.blue900),
      ),
    );
  }
}
