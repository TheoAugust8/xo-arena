part of 'package:xo_arena/shared/settings/presentation/widgets/settings_sheet.dart';

class _DifficultyRail extends StatelessWidget {
  const _DifficultyRail({required this.selected, required this.onChanged});

  final GameDifficulty selected;
  final Future<void> Function(GameDifficulty value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('settings_difficulty_rail'),
      height: 48,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: context.appTokens.surface2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: GameDifficulty.values
            .map(
              (value) => Expanded(
                child: _DifficultyOption(
                  value: value,
                  selected: value == selected,
                  onPressed: () => unawaited(onChanged(value)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  const _DifficultyOption({
    required this.value,
    required this.selected,
    required this.onPressed,
  });

  final GameDifficulty value;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
    final label = value.label(context.l10n);
    return Semantics(
      key: ValueKey('settings_difficulty_${value.name}'),
      button: true,
      selected: selected,
      label: selected
          ? context.l10n.difficultyOptionSelected(label)
          : context.l10n.difficultyOption(label),
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? tokens.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? Colors.white : tokens.foregroundSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
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
