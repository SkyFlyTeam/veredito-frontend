import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class SearchInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hintText;
  final String? labelText;
  final InputDecoration? decoration;
  final int? maxLines;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  const SearchInput({
    Key? key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText = 'Buscar',
    this.labelText,
    this.decoration,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.search,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleClear() {
    widget.controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      inputFormatters: widget.inputFormatters,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: GoogleFonts.montserrat(
        color: AppColors.gray100,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      decoration:
          widget.decoration ??
          InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            prefixIcon: const Icon(Icons.search, color: AppColors.gray200),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.gray200),
                    onPressed: _handleClear,
                  )
                : null,
            filled: false,
          ),
    );
  }
}
