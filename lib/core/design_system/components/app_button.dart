import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton.primary({
    required this.label,
    this.onPressed,
    this.icon,
    super.key,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    required this.label,
    this.onPressed,
    this.icon,
    super.key,
  }) : variant = AppButtonVariant.secondary;

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final child = Text(label);

    return switch ((variant, icon)) {
      (AppButtonVariant.primary, final Widget icon) => FilledButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: child,
      ),
      (AppButtonVariant.primary, null) => FilledButton(
        onPressed: onPressed,
        child: child,
      ),
      (AppButtonVariant.secondary, final Widget icon) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: child,
      ),
      (AppButtonVariant.secondary, null) => OutlinedButton(
        onPressed: onPressed,
        child: child,
      ),
    };
  }
}
