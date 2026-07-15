part of 'package:xo_arena/features/game/presentation/game_screen.dart';

class _MatchDivider extends StatelessWidget {
  const _MatchDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
          child: Text(
            context.l10n.match,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _RestartButton extends StatelessWidget {
  const _RestartButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        key: const ValueKey('game_new_game_button'),
        onPressed: onPressed,
        icon: const Icon(Icons.refresh, size: 16),
        label: Text(context.l10n.newGame),
      ),
    );
  }
}

GameStatusVariant _statusVariantFor(GameState state) {
  if (state.isCpuThinking) return GameStatusVariant.cpu;
  return switch ((state.game.status, state.game.winner)) {
    (GameStatus.active, _) => GameStatusVariant.player,
    (GameStatus.won, GamePlayer.human) => GameStatusVariant.playerWin,
    (GameStatus.won, GamePlayer.cpu) => GameStatusVariant.cpuWin,
    (GameStatus.draw, _) => GameStatusVariant.draw,
    _ => GameStatusVariant.player,
  };
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({
    required this.difficulty,
    required this.isCpuThinking,
  });

  final GameDifficulty difficulty;
  final bool isCpuThinking;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final color = switch (difficulty) {
      GameDifficulty.easy => tokens.win,
      GameDifficulty.medium => tokens.warn,
      GameDifficulty.hard => tokens.primary,
    };
    return Semantics(
      label: context.l10n.difficultyOption(difficulty.label(context.l10n)),
      excludeSemantics: true,
      child: DecoratedBox(
        key: const ValueKey('game_difficulty_badge'),
        decoration: BoxDecoration(
          color: tokens.surface2,
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space12,
            vertical: 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GameActivityDot(color: color, size: 6, isPulsing: isCpuThinking),
              const SizedBox(width: 6),
              Text(
                difficulty.label(context.l10n).toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: tokens.mutedForeground,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
