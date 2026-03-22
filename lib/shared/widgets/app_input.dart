import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum AppInputVisualState { defaultState, error, variation3 }

const double _figmaBaseWidth = 304;
const double _pixel9ProWidth = 412;

class AppInput extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final bool enablePasswordToggle;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final AppInputVisualState visualState;
  final double? width;
  final double inputHeight;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final String? errorMessage;

  const AppInput({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.enablePasswordToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.visualState = AppInputVisualState.defaultState,
    this.width,
    this.inputHeight = 67,
    this.borderRadius = 12,
    this.contentPadding,
    this.errorMessage,
  });

  const AppInput.error({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.enablePasswordToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.width,
    this.inputHeight = 67,
    this.borderRadius = 12,
    this.contentPadding,
    this.errorMessage,
  }) : visualState = AppInputVisualState.error;

  const AppInput.variation3({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.enablePasswordToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.width,
    this.inputHeight = 67,
    this.borderRadius = 12,
    this.contentPadding,
    this.errorMessage,
  }) : visualState = AppInputVisualState.variation3;

  const AppInput.password({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.visualState = AppInputVisualState.defaultState,
    this.width,
    this.inputHeight = 67,
    this.borderRadius = 12,
    this.contentPadding,
    this.errorMessage,
  }) : suffixIcon = null,
       obscureText = true,
       enablePasswordToggle = true;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late bool _isObscured;
  static const double _labelFontSize = 16;
  static const double _labelBottomSpacing = 8;
  static const double _minFieldHeight = 36;

  double _effectiveWidth(BuildContext context, {double? maxParentWidth}) {
    if (widget.width != null) {
      return widget.width!;
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final parentWidth = maxParentWidth != null && maxParentWidth.isFinite
        ? maxParentWidth
        : double.infinity;
    final availableWidth = (screenWidth - 32).clamp(0, parentWidth).toDouble();

    if (screenWidth <= _pixel9ProWidth) {
      return _figmaBaseWidth.clamp(0, availableWidth).toDouble();
    }

    final responsiveWidth =
        availableWidth * (_figmaBaseWidth / _pixel9ProWidth);
    return responsiveWidth.clamp(_figmaBaseWidth, availableWidth).toDouble();
  }

  Color _labelColor() {
    switch (widget.visualState) {
      case AppInputVisualState.defaultState:
      case AppInputVisualState.error:
        return AppColors.gray100;
      case AppInputVisualState.variation3:
        return AppColors.gray300;
    }
  }

  Color _hintColor() {
    switch (widget.visualState) {
      case AppInputVisualState.defaultState:
      case AppInputVisualState.variation3:
        return AppColors.gray300;
      case AppInputVisualState.error:
        return AppColors.red300;
    }
  }

  Color _outlineColor() {
    switch (widget.visualState) {
      case AppInputVisualState.defaultState:
      case AppInputVisualState.variation3:
        return AppColors.gray100;
      case AppInputVisualState.error:
        return AppColors.red300;
    }
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = _labelColor();
    final hintColor = _hintColor();
    final outlineColor = _outlineColor();

    final Widget? effectiveSuffixIcon = widget.enablePasswordToggle
        ? IconButton(
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
            icon: Icon(
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: AppColors.gray300,
            ),
          )
        : widget.suffixIcon;

    final bool showErrorMessage =
        widget.visualState == AppInputVisualState.error &&
        widget.errorMessage != null &&
        widget.errorMessage!.trim().isNotEmpty;

    final bool hasLabel =
        widget.labelText != null && widget.labelText!.trim().isNotEmpty;
    final labelSectionHeight = hasLabel
        ? (_labelFontSize + _labelBottomSpacing)
        : 0.0;
    final fieldHeight = (widget.inputHeight - labelSectionHeight)
        .clamp(_minFieldHeight, double.infinity)
        .toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = _effectiveWidth(
          context,
          maxParentWidth: constraints.maxWidth,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.inputHeight),
              child: SizedBox(
                width: effectiveWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasLabel)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: _labelBottomSpacing,
                        ),
                        child: Text(
                          widget.labelText!,
                          style: TextStyle(
                            color: labelColor,
                            fontSize: _labelFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: fieldHeight,
                      child: TextFormField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        enabled: widget.enabled,
                        readOnly: widget.readOnly,
                        obscureText: _isObscured,
                        keyboardType: widget.keyboardType,
                        textInputAction: widget.textInputAction,
                        validator: widget.validator,
                        onChanged: widget.onChanged,
                        onFieldSubmitted: widget.onSubmitted,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(color: hintColor),
                          isDense: true,
                          contentPadding:
                              widget.contentPadding ??
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                          prefixIcon: widget.prefixIcon,
                          suffixIcon: effectiveSuffixIcon,
                          enabledBorder: _border(outlineColor),
                          focusedBorder: _border(outlineColor, width: 2),
                          errorBorder: _border(AppColors.red300),
                          focusedErrorBorder: _border(
                            AppColors.red300,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showErrorMessage)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  widget.errorMessage!,
                  style: const TextStyle(
                    color: AppColors.red300,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
