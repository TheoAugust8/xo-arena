import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_theme_tokens.dart';

class AppIconControl extends StatelessWidget {
  const AppIconControl({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.visualSize = 40,
    this.iconSize = 18,
    super.key,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final double visualSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        label: tooltip,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Ink(
                  width: visualSize,
                  height: visualSize,
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tokens.border),
                  ),
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: onPressed == null
                        ? tokens.mutedForeground
                        : tokens.foregroundSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
