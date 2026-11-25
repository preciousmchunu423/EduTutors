import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum AppButtonStyle { primary, accent, outline }

/// One button used across the app so sizing and colours never drift.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool loading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final fg = style == AppButtonStyle.outline
        ? AppColors.blue
        : style == AppButtonStyle.accent
            ? AppColors.navy
            : AppColors.white;

    final child = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final VoidCallback? action = loading ? null : onPressed;

    final Widget button;
    switch (style) {
      case AppButtonStyle.outline:
        button = OutlinedButton(onPressed: action, child: child);
        break;
      case AppButtonStyle.accent:
        button = ElevatedButton(
          onPressed: action,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.yellow,
            foregroundColor: AppColors.navy,
          ),
          child: child,
        );
        break;
      case AppButtonStyle.primary:
        button = ElevatedButton(onPressed: action, child: child);
        break;
    }

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
