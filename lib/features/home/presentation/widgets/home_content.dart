part of 'package:xo_arena/features/home/presentation/home_screen.dart';

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.history,
    required this.difficulty,
    required this.disableAnimations,
    required this.fillsAvailableHeight,
    required this.onSettings,
    required this.onDifficultyChanged,
    required this.onPlay,
    required this.onHistory,
    required this.onRetryHistory,
  });

  final AsyncValue<List<GameRecord>> history;
  final GameDifficulty difficulty;
  final bool disableAnimations;
  final bool fillsAvailableHeight;
  final VoidCallback onSettings;
  final ValueChanged<GameDifficulty> onDifficultyChanged;
  final VoidCallback onPlay;
  final VoidCallback onHistory;
  final VoidCallback onRetryHistory;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final hero = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Reveal(enabled: !disableAnimations, child: const AppLogo(size: 96)),
        const SizedBox(height: AppSpacing.space24),
        Text(
          'ARENA',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: tokens.primary,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        Text('XO ARENA', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: AppSpacing.space8),
        Text(
          'Prove your edge against the machine.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.space32),
        _HistorySummary(history: history, onRetry: onRetryHistory),
      ],
    );
    final actions = Column(
      children: [
        Text('DIFFICULTY', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.space8),
        _DifficultyRail(
          selected: difficulty,
          disableAnimations: disableAnimations,
          onChanged: onDifficultyChanged,
        ),
        const SizedBox(height: AppSpacing.space16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: onPlay,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('PLAY NOW'),
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onHistory,
            icon: const Icon(Icons.bar_chart_rounded),
            label: const Text('VIEW HISTORY'),
          ),
        ),
      ],
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.space12),
          child: Align(
            alignment: Alignment.centerRight,
            child: AppIconControl(
              key: const ValueKey('home_settings_button'),
              tooltip: 'Settings',
              icon: Icons.settings_outlined,
              onPressed: onSettings,
            ),
          ),
        ),
        if (fillsAvailableHeight)
          Expanded(child: Center(child: hero))
        else ...[
          const SizedBox(height: AppSpacing.space32),
          hero,
          const SizedBox(height: AppSpacing.space32),
        ],
        actions,
        const SizedBox(height: AppSpacing.space16),
      ],
    );
  }
}
