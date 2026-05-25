import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  static const double _iconOnlySize = 50;

  final String? label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final ButtonStyle? style;
  final MainAxisSize mainAxisSize;
  final double spacing;
  final Widget? loadingWidget;

  const AppButton({
    super.key,
    this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.style,
    this.mainAxisSize = MainAxisSize.min,
    this.spacing = 8,
    this.loadingWidget,
  }) : assert(
         label != null || icon != null,
         'AppButton precisa ter label ou icon.',
       );

  @override
  Widget build(BuildContext context) {
    final themeButtonStyle = Theme.of(context).elevatedButtonTheme.style;
    final enabledBackgroundColor = themeButtonStyle?.backgroundColor?.resolve(
      const {},
    );
    final enabledForegroundColor = themeButtonStyle?.foregroundColor?.resolve(
      const {},
    );

    final foregroundColor = enabledForegroundColor;

    final hasLabel = label != null && label!.trim().isNotEmpty;
    final hasIcon = icon != null;
    final isIconOnly = hasIcon && !hasLabel;

    final child = isLoading
        ? (loadingWidget ??
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: foregroundColor,
                      strokeWidth: 2,
                    ),
                  ),
                  if (hasLabel) SizedBox(width: spacing),
                  if (hasLabel) Text(label!),
                ],
              ))
        : Row(
            mainAxisSize: mainAxisSize,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasIcon) Icon(icon),
              if (hasIcon && hasLabel) SizedBox(width: spacing),
              if (hasLabel) Text(label!),
            ],
          );

    final iconOnlyStyle = isIconOnly
        ? ElevatedButton.styleFrom(
            minimumSize: const Size(_iconOnlySize, _iconOnlySize),
            fixedSize: const Size(_iconOnlySize, _iconOnlySize),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )
        : null;

    final loadingStyle = isLoading
        ? ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(enabledBackgroundColor),
            foregroundColor: WidgetStatePropertyAll(enabledForegroundColor),
          )
        : null;

    final baseStyle = isIconOnly ? iconOnlyStyle?.merge(style) : style;
    final effectiveStyle = baseStyle?.merge(loadingStyle) ?? loadingStyle;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: effectiveStyle,
      child: Center(child: child),
    );
  }
}
