import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/core/design_system/components/app_icon_control.dart';
import 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';
import 'package:xo_arena/core/design_system/components/app_logo.dart';
import 'package:xo_arena/features/history/presentation/history_providers.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/settings/presentation/settings_ui.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record_stats.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  var _isMutating = false;

  Future<bool> _delete(String id) async {
    setState(() => _isMutating = true);
    try {
      await ref.read(deleteGameRecordUseCaseProvider)(id);
      if (!mounted) return false;
      ref.invalidate(gameRecordsProvider);
      return true;
    } on Object {
      _showMutationError('Unable to delete match.');
      return false;
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (context) => const _ClearHistoryDialog(),
    );
    if (!mounted) return;
    if (confirmed == true) await _clear();
  }

  Future<void> _clear() async {
    setState(() => _isMutating = true);
    try {
      await ref.read(clearHistoryUseCaseProvider)();
      if (!mounted) return;
      ref.invalidate(gameRecordsProvider);
    } on Object {
      _showMutationError('Unable to clear match history.');
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  void _showMutationError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(gameRecordsProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                _HistoryHeader(
                  isMutating: _isMutating,
                  hasRecords: history.value?.isNotEmpty ?? false,
                  onBack: () => context.go('/'),
                  onClear: _confirmClear,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.space20),
                  child: Divider(),
                ),
                Expanded(
                  child: history.when(
                    data: (records) {
                      if (records.isEmpty) {
                        return _EmptyHistory(onPlay: () => context.go('/game'));
                      }
                      final newestFirst = [...records]
                        ..sort(
                          (first, second) =>
                              second.completedAt.compareTo(first.completedAt),
                        );
                      return _HistoryList(
                        records: newestFirst,
                        isMutating: _isMutating,
                        onDelete: _delete,
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, _) => _HistoryError(
                      onRetry: () => ref.invalidate(gameRecordsProvider),
                    ),
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

class _ClearHistoryDialog extends StatelessWidget {
  const _ClearHistoryDialog();

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Dialog(
      backgroundColor: tokens.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: tokens.border),
      ),
      child: SizedBox(
        key: const ValueKey('clear_history_dialog'),
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                key: const ValueKey('clear_history_dialog_icon'),
                decoration: BoxDecoration(
                  color: tokens.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 52,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: tokens.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'Clear all match history?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: tokens.foreground,
                  fontFamily: 'Barlow Condensed',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                'Completed matches will be removed permanently.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.mutedForeground,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.space24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      key: const ValueKey('cancel_clear_history'),
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('CANCEL'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: SizedBox(
                      key: const ValueKey('confirm_clear_history'),
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: const Text('CLEAR'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({
    required this.isMutating,
    required this.hasRecords,
    required this.onBack,
    required this.onClear,
  });

  final bool isMutating;
  final bool hasRecords;
  final VoidCallback onBack;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space20,
        AppSpacing.space12,
        AppSpacing.space12,
        AppSpacing.space12,
      ),
      child: largeText
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _BackButton(onPressed: onBack),
                    const Spacer(),
                    if (hasRecords)
                      _ClearButton(isMutating: isMutating, onPressed: onClear),
                  ],
                ),
                const SizedBox(height: AppSpacing.space12),
                const _HistoryTitle(),
              ],
            )
          : Row(
              children: [
                _BackButton(onPressed: onBack),
                const SizedBox(width: AppSpacing.space12),
                const Expanded(child: _HistoryTitle()),
                if (hasRecords)
                  _ClearButton(isMutating: isMutating, onPressed: onClear),
              ],
            ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Tooltip(
      message: 'Back to Home',
      child: SizedBox(
        width: 48,
        height: 48,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Ink(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tokens.surface,
                  border: Border.all(color: tokens.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: tokens.foregroundSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.isMutating, required this.onPressed});

  final bool isMutating;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppIconControl(
      key: const Key('clear-history'),
      tooltip: 'Clear match history',
      icon: Icons.delete_outline_rounded,
      onPressed: isMutating ? null : onPressed,
    );
  }
}

class _HistoryTitle extends StatelessWidget {
  const _HistoryTitle();

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'XO ARENA',
          style: TextStyle(
            color: tokens.primary,
            fontFamily: 'Inter',
            fontSize: 9,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Match History',
          style: TextStyle(
            color: tokens.foreground,
            fontFamily: 'Barlow Condensed',
            fontSize: 22,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

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

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.stats});

  final GameRecordStats stats;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final summaryHeight = MediaQuery.textScalerOf(context).scale(1) > 1.25
        ? 84.0
        : 64.0;
    final values = [
      (stats.wins, 'W', tokens.win),
      (stats.draws, 'D', tokens.draw),
      (stats.losses, 'L', tokens.primary),
    ];
    return SizedBox(
      key: const ValueKey('history_summary'),
      height: summaryHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            for (var index = 0; index < values.length; index++) ...[
              Expanded(
                child: _SummaryValue(
                  value: values[index].$1,
                  label: values[index].$2,
                  color: values[index].$3,
                ),
              ),
              if (index < values.length - 1)
                VerticalDivider(width: 1, thickness: 1, color: tokens.border),
            ],
            SizedBox(
              width: 72,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.primary,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(15),
                  ),
                ),
                child: _SummaryValue(
                  value: '${stats.winRate}%',
                  label: 'WIN',
                  color: Colors.white,
                  labelColor: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.value,
    required this.label,
    required this.color,
    this.labelColor,
  });

  final Object value;
  final String label;
  final Color color;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$value',
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Barlow Condensed',
                color: color,
                fontSize: 24,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Inter',
                color: labelColor,
                fontSize: 9,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
        record.playerOneName == 'You'
            ? 'YOU WIN'
            : '${record.playerOneName} won',
        tokens.win,
        tokens.win.withValues(alpha: 0.12),
      ),
      GameOutcome.playerTwoWin => (
        record.playerTwoName == 'CPU'
            ? 'CPU WINS'
            : '${record.playerTwoName} won',
        tokens.primary,
        tokens.primary.withValues(alpha: 0.12),
      ),
      GameOutcome.draw => (
        'DRAW',
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
            fontFamily: 'Barlow Condensed',
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
            Text(record.difficulty.label, style: style),
          ],
        ),
        Text('${record.moveCount} moves', style: style),
        Text(record.skin.label, style: style),
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
      label: 'Completed $absolute',
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
              _relativeTime(local),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 10, height: 1),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
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

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onPlay});

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(opacity: 0.35, child: const AppLogo(size: 64)),
            const SizedBox(height: AppSpacing.space20),
            Text(
              'No completed games yet.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.space8),
            Text(
              'Play your first game to build match history.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.space20),
            FilledButton(onPressed: onPlay, child: const Text('START PLAYING')),
          ],
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: AppSpacing.space12),
            const Text('Unable to load match history.'),
            const SizedBox(height: AppSpacing.space12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}
