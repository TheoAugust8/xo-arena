part of 'package:xo_arena/features/history/presentation/history_screen.dart';

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.record,
    required this.isMutating,
    required this.onDelete,
  });

  final GameRecord record;
  final bool isMutating;
  final Future<bool> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final (label, color, background) = switch (record.outcome) {
      GameOutcome.playerOneWin => (
        record.playerOneName == GameRecordParticipants.human
            ? context.l10n.youWinCompact
            : context.l10n.playerWon(record.playerOneName),
        tokens.win,
        tokens.win.withValues(alpha: 0.12),
      ),
      GameOutcome.playerTwoWin => (
        record.playerTwoName == GameRecordParticipants.cpu
            ? context.l10n.cpuWins
            : context.l10n.playerWon(record.playerTwoName),
        tokens.primary,
        tokens.primary.withValues(alpha: 0.12),
      ),
      GameOutcome.draw => (
        context.l10n.draw,
        tokens.draw,
        tokens.draw.withValues(alpha: 0.1),
      ),
    };
    return Dismissible(
      key: Key('dismiss-${record.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) =>
          isMutating ? Future.value(false) : onDelete(record.id),
      background: const SizedBox.expand(),
      secondaryBackground: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: AppSpacing.space20),
            child: Icon(Icons.delete_outline, color: Colors.white),
          ),
        ),
      ),
      child: ConstrainedBox(
        key: ValueKey('history_card_${record.id}'),
        constraints: const BoxConstraints(minHeight: 68),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.surface,
            border: Border.all(color: tokens.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space12,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 4,
                  height: 44,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OutcomeBadge(
                        label: label,
                        color: color,
                        background: background,
                      ),
                      const SizedBox(height: 6),
                      _CardMetadata(record: record),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space12),
                SizedBox(
                  width: 72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _CompletedTime(completedAt: record.completedAt),
                      const SizedBox(height: AppSpacing.space8),
                      _HistorySymbols(record: record),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutcomeBadge extends StatelessWidget {
  const _OutcomeBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontFamily: AppFonts.display,
            fontSize: 13,
            height: 1,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _CardMetadata extends StatelessWidget {
  const _CardMetadata({required this.record});

  final GameRecord record;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final difficultyColor = switch (record.difficulty) {
      GameDifficulty.easy => tokens.win,
      GameDifficulty.medium => tokens.warn,
      GameDifficulty.hard => tokens.primary,
    };
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: tokens.mutedForeground,
      fontSize: 11,
    );
    return Wrap(
      spacing: AppSpacing.space12,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: difficultyColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(record.difficulty.label(context.l10n), style: style),
          ],
        ),
        Text(context.l10n.moveCount(record.moveCount), style: style),
        Text(record.skin.label(context.l10n), style: style),
      ],
    );
  }
}

class _HistorySymbols extends StatelessWidget {
  const _HistorySymbols({required this.record});

  final GameRecord record;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: ValueKey('history_symbols_${record.id}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final mark in GameSymbolMark.values) ...[
          if (mark != GameSymbolMark.x) const SizedBox(width: 4),
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.appTokens.surface2,
              borderRadius: BorderRadius.circular(6),
            ),
            child: GameSymbol(mark: mark, skin: record.skin, size: 16),
          ),
        ],
      ],
    );
  }
}

class _CompletedTime extends StatelessWidget {
  const _CompletedTime({required this.completedAt});

  final DateTime completedAt;

  @override
  Widget build(BuildContext context) {
    final local = completedAt.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final absolute =
        '${localizations.formatShortDate(local)} ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
    return Semantics(
      label: context.l10n.completedAt(absolute),
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 12,
              color: context.appTokens.mutedForeground,
            ),
            const SizedBox(width: 4),
            Text(
              _relativeTime(local, context.l10n),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 10, height: 1),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime time, AppLocalizations l10n) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 1) return l10n.justNow;
    if (difference.inHours < 1) return l10n.minutesAgo(difference.inMinutes);
    if (difference.inDays < 1) return l10n.hoursAgo(difference.inHours);
    return l10n.daysAgo(difference.inDays);
  }
}
