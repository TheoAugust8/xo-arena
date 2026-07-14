part of 'package:xo_arena/features/history/presentation/history_screen.dart';

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.records,
    required this.isMutating,
    required this.onDelete,
  });

  final List<GameRecord> records;
  final bool isMutating;
  final Future<bool> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final stats = GameRecordStats.fromRecords(records);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space20,
        AppSpacing.space16,
        AppSpacing.space20,
        AppSpacing.space32,
      ),
      children: [
        _SummaryBar(stats: stats),
        const SizedBox(height: AppSpacing.space20),
        for (var index = 0; index < records.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space8),
            child: _HistoryReveal(
              enabled: !disableAnimations,
              index: index,
              child: _HistoryCard(
                record: records[index],
                isMutating: isMutating,
                onDelete: onDelete,
              ),
            ),
          ),
      ],
    );
  }
}

class _HistoryReveal extends StatelessWidget {
  const _HistoryReveal({
    required this.enabled,
    required this.index,
    required this.child,
  });

  final bool enabled;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: enabled ? 0 : 1, end: 1),
      duration: enabled
          ? Duration(milliseconds: 220 + index * 40)
          : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(18 * (1 - value), 0),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
