import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_radius.dart';
import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';

enum GameStatusVariant { player, cpu, playerWin, cpuWin, draw }

extension GameStatusVariantLabel on GameStatusVariant {
  String get label => switch (this) {
    GameStatusVariant.player => 'YOUR TURN',
    GameStatusVariant.cpu => 'CPU THINKING',
    GameStatusVariant.playerWin => 'YOU WIN!',
    GameStatusVariant.cpuWin => 'CPU WINS',
    GameStatusVariant.draw => 'DRAW',
  };
}

class GameStatusBadge extends StatelessWidget {
  const GameStatusBadge({required this.variant, super.key});

  final GameStatusVariant variant;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final color = switch (variant) {
      GameStatusVariant.player => tokens.win,
      GameStatusVariant.cpu => tokens.warn,
      GameStatusVariant.playerWin => tokens.win,
      GameStatusVariant.cpuWin => tokens.primary,
      GameStatusVariant.draw => tokens.draw,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 550),
              width: AppSpacing.space8,
              height: AppSpacing.space8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.space8),
            Text(
              variant.label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
