import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_radius.dart';
import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';

class GameScore extends StatelessWidget {
  const GameScore({
    required this.playerScore,
    required this.cpuScore,
    required this.playerMark,
    required this.cpuMark,
    this.skin = GameSymbolSkin.classic,
    super.key,
  });

  final int playerScore;
  final int cpuScore;
  final GameSymbolMark playerMark;
  final GameSymbolMark cpuMark;
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
                mark: playerMark,
                label: 'YOU',
                value: playerScore,
                skin: skin,
                isHuman: true,
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
                mark: cpuMark,
                label: 'CPU',
                value: cpuScore,
                skin: skin,
                isHuman: false,
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
    required this.isHuman,
    this.labelFirst = false,
  });

  final GameSymbolMark mark;
  final String label;
  final int value;
  final GameSymbolSkin skin;
  final bool isHuman;
  final bool labelFirst;

  @override
  Widget build(BuildContext context) {
    final header = <Widget>[
      _SymbolTile(mark: mark, skin: skin, isHuman: isHuman),
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
        _AnimatedScoreValue(value: value),
      ],
    );
  }
}

class _AnimatedScoreValue extends StatelessWidget {
  const _AnimatedScoreValue({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);
    final score = Text(
      '$value',
      style: Theme.of(context).textTheme.displayMedium,
    );

    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: duration,
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.4, end: 1).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
      ),
      child: KeyedSubtree(key: ValueKey(value), child: score),
    );
  }
}

class _SymbolTile extends StatelessWidget {
  const _SymbolTile({
    required this.mark,
    required this.skin,
    required this.isHuman,
  });

  final GameSymbolMark mark;
  final GameSymbolSkin skin;
  final bool isHuman;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isHuman ? tokens.primary : tokens.surface,
        border: isHuman ? null : Border.all(color: tokens.borderStrong),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: SizedBox.square(
        dimension: 28,
        child: Center(
          child: isHuman
              ? ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: GameSymbol(mark: mark, skin: skin, size: 14),
                )
              : GameSymbol(mark: mark, skin: skin, size: 14),
        ),
      ),
    );
  }
}
