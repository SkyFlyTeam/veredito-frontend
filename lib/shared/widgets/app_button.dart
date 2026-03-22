import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum AppButtonVisualState { defaultState, loading, disabled, iconOnly }

class AppButton extends StatelessWidget {
  static const double _pixel9ProWidth = 412;
  static const double _defaultWidth = 304;
  static const double _defaultHeight = 41;
  static const double _iconOnlySize = 50;
  static const double _iconOnlyIconSize = 30;
  static const double _borderRadius = 10;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVisualState visualState;
  final IconData? icon;
  final double width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = _defaultWidth,
    this.height = _defaultHeight,
  }) : visualState = AppButtonVisualState.defaultState,
       icon = null;

  const AppButton.loading({
    super.key,
    required this.label,
    this.width = _defaultWidth,
    this.height = _defaultHeight,
  }) : onPressed = null,
       visualState = AppButtonVisualState.loading,
       icon = null;

  const AppButton.disabled({
    super.key,
    required this.label,
    this.width = _defaultWidth,
    this.height = _defaultHeight,
  }) : onPressed = null,
       visualState = AppButtonVisualState.disabled,
       icon = null;

  const AppButton.icon({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  }) : width = _iconOnlySize,
       height = _iconOnlySize,
       visualState = AppButtonVisualState.iconOnly;

  Color _backgroundColor() {
    switch (visualState) {
      case AppButtonVisualState.disabled:
        return AppColors.gray300;
      case AppButtonVisualState.defaultState:
      case AppButtonVisualState.loading:
      case AppButtonVisualState.iconOnly:
        return AppColors.purple200;
    }
  }

  Color _foregroundColor() {
    switch (visualState) {
      case AppButtonVisualState.disabled:
        return AppColors.gray100.withValues(alpha: 0.75);
      case AppButtonVisualState.defaultState:
      case AppButtonVisualState.loading:
      case AppButtonVisualState.iconOnly:
        return AppColors.gray100;
    }
  }

  bool get _isLoading => visualState == AppButtonVisualState.loading;

  bool get _isEnabled {
    if (_isLoading || visualState == AppButtonVisualState.disabled) {
      return false;
    }
    return onPressed != null;
  }

  Widget _buildChild(double scale) {
    final foreground = _foregroundColor();

    if (visualState == AppButtonVisualState.iconOnly) {
      return Center(
        child: Icon(icon, color: foreground, size: _iconOnlyIconSize * scale),
      );
    }

    if (_isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14 * scale,
            height: 14 * scale,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          ),
          SizedBox(width: 8 * scale),
          Text(label),
        ],
      );
    }

    return Text(label);
  }

  @override
  Widget build(BuildContext context) {
    final isIconOnly = visualState == AppButtonVisualState.iconOnly;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = screenWidth / _pixel9ProWidth;

    final scaledWidth = width * scale;
    final scaledHeight = height * scale;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: _backgroundColor(),
      foregroundColor: _foregroundColor(),
      elevation: 0,
      alignment: Alignment.center,
      padding: isIconOnly ? EdgeInsets.zero : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius * scale),
      ),
      textStyle: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w600),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxParentWidth = constraints.maxWidth;
        final effectiveWidth = maxParentWidth.isFinite
            ? scaledWidth.clamp(0, maxParentWidth).toDouble()
            : scaledWidth;

        return SizedBox(
          width: effectiveWidth,
          height: scaledHeight,
          child: ElevatedButton(
            onPressed: _isEnabled ? onPressed : null,
            style: buttonStyle,
            child: _buildChild(scale),
          ),
        );
      },
    );
  }
}
