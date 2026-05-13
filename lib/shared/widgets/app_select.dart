import 'package:flutter/material.dart';

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
    );
  }
}
