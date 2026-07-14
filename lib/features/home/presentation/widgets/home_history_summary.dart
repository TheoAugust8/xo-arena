part of 'package:xo_arena/features/home/presentation/home_screen.dart';

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({required this.history, required this.onRetry});

  final AsyncValue<List<GameRecord>> history;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return history.when(
      data: (records) {
        if (records.isEmpty) return const SizedBox.shrink();
        final stats = GameRecordStats.fromRecords(records);
        return _StatsStrip(stats: stats);
      },
      loading: () => const SizedBox(
        height: 42,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Retry stats'),
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.stats});

  final GameRecordStats stats;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final values = [
      (stats.wins, 'WINS', tokens.win),
      (stats.draws, 'DRAWS', tokens.draw),
      (stats.losses, 'LOSSES', tokens.primary),
    ];
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            for (var index = 0; index < values.length; index++) ...[
              if (index > 0)
                SizedBox(
                  height: 32,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: tokens.border,
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space8,
                    vertical: AppSpacing.space12,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${values[index].$1}',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: values[index].$3),
                      ),
                      Text(
                        values[index].$2,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
