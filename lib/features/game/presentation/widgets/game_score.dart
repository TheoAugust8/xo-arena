import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_radius.dart';
import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/features/game/presentation/models/game_symbol_skin.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_symbol.dart';

class GameScore extends StatelessWidget {
  const GameScore({
    required this.playerScore,
    required this.cpuScore,
    this.skin = GameSymbolSkin.classic,
    super.key,
  });

  final int playerScore;
  final int cpuScore;
  final GameSymbolSkin skin;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space20,
          vertical: AppSpacing.space12,
        ),
        child: Row(
          children: [
            Expanded(
              child: _ScoreSide(
                mark: GameSymbolMark.x,
                label: 'YOU',
                value: playerScore,
                skin: skin,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'VS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Container(width: 1, height: 32, color: tokens.border),
                ],
              ),
            ),
            Expanded(
              child: _ScoreSide(
                mark: GameSymbolMark.o,
                label: 'CPU',
                value: cpuScore,
                skin: skin,
                labelFirst: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreSide extends StatelessWidget {
  const _ScoreSide({
    required this.mark,
    required this.label,
    required this.value,
    required this.skin,
    this.labelFirst = false,
  });

  final GameSymbolMark mark;
  final String label;
  final int value;
  final GameSymbolSkin skin;
  final bool labelFirst;

  @override
  Widget build(BuildContext context) {
    final header = <Widget>[
      _SymbolTile(mark: mark, skin: skin),
      const SizedBox(width: AppSpacing.space8),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: labelFirst ? header.reversed.toList() : header,
        ),
        const SizedBox(height: AppSpacing.space8),
        Text('$value', style: Theme.of(context).textTheme.displayMedium),
      ],
    );
  }
}

class _SymbolTile extends StatelessWidget {
  const _SymbolTile({required this.mark, required this.skin});

  final GameSymbolMark mark;
  final GameSymbolSkin skin;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final isPlayer = mark == GameSymbolMark.x;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isPlayer ? tokens.primary : tokens.surface,
        border: isPlayer ? null : Border.all(color: tokens.borderStrong),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: SizedBox.square(
        dimension: 28,
        child: Center(
          child: isPlayer
              ? const Text(
                  'X',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Barlow Condensed',
                    fontWeight: FontWeight.w900,
                  ),
                )
              : GameSymbol(mark: mark, skin: skin, size: 14),
        ),
      ),
    );
  }
}
