import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_radius.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/features/game/presentation/models/game_symbol_skin.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_symbol.dart';

enum GameCellVariant { empty, playerX, cpuO, pressed, disabled, winning }

class GameCell extends StatelessWidget {
  const GameCell({
    required this.variant,
    this.mark,
    this.skin = GameSymbolSkin.classic,
    this.dimension = 88,
    this.onPressed,
    super.key,
  });

  final GameCellVariant variant;
  final GameSymbolMark? mark;
  final GameSymbolSkin skin;
  final double dimension;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final enabled = variant != GameCellVariant.disabled && onPressed != null;
    final background = switch (variant) {
      GameCellVariant.playerX => tokens.xCellBackground,
      GameCellVariant.cpuO => tokens.oCellBackground,
      GameCellVariant.pressed => tokens.cellPressedBackground,
      GameCellVariant.winning => tokens.winBackground,
      GameCellVariant.disabled || GameCellVariant.empty => tokens.surface,
    };
    final border = switch (variant) {
      GameCellVariant.playerX => tokens.primary.withValues(alpha: 0.28),
      GameCellVariant.cpuO || GameCellVariant.pressed => tokens.borderStrong,
      GameCellVariant.winning => tokens.win,
      _ => tokens.border,
    };
    final resolvedMark =
        mark ??
        switch (variant) {
          GameCellVariant.playerX ||
          GameCellVariant.disabled ||
          GameCellVariant.winning => GameSymbolMark.x,
          GameCellVariant.cpuO => GameSymbolMark.o,
          _ => null,
        };

    return Semantics(
      button: true,
      enabled: enabled,
      label: resolvedMark?.name.toUpperCase() ?? 'Empty cell',
      child: Opacity(
        opacity: variant == GameCellVariant.disabled ? 0.38 : 1,
        child: SizedBox.square(
          dimension: dimension,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: variant == GameCellVariant.winning
                  ? [
                      BoxShadow(
                        color: tokens.win.withValues(alpha: 0.2),
                        blurRadius: 20,
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: BorderSide(
                  color: border,
                  width: variant == GameCellVariant.winning ? 2 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: enabled ? onPressed : null,
                child: Center(
                  child: resolvedMark == null
                      ? null
                      : GameSymbol(mark: resolvedMark, skin: skin, size: 48),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
