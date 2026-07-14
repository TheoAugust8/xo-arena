part of 'package:xo_arena/features/home/presentation/home_screen.dart';

class _DifficultyRail extends StatelessWidget {
  const _DifficultyRail({
    required this.selected,
    required this.disableAnimations,
    required this.onChanged,
  });

  final GameDifficulty selected;
  final bool disableAnimations;
  final ValueChanged<GameDifficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            key: const ValueKey('home_difficulty_rail'),
            width: double.infinity,
            height: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Row(
            children: [
              for (final difficulty in GameDifficulty.values)
                Expanded(
                  child: _DifficultyOption(
                    difficulty: difficulty,
                    selected: selected == difficulty,
                    disableAnimations: disableAnimations,
                    onPressed: () => onChanged(difficulty),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  const _DifficultyOption({
    required this.difficulty,
    required this.selected,
    required this.disableAnimations,
    required this.onPressed,
  });

  final GameDifficulty difficulty;
  final bool selected;
  final bool disableAnimations;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final label =
        '${difficulty.label} difficulty${selected ? ', selected' : ''}';
    return Semantics(
      label: label,
      button: true,
      selected: selected,
      onTap: onPressed,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: AnimatedContainer(
              key: ValueKey('home_difficulty_${difficulty.name}'),
              duration: disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? tokens.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                difficulty.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected ? Colors.white : tokens.foregroundSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
