import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';

import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/features/history/presentation/history_providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  var _isMutating = false;

  Future<void> _delete(String id) async {
    setState(() => _isMutating = true);
    try {
      await ref.read(deleteGameRecordUseCaseProvider)(id);
      if (mounted) {
        ref.invalidate(gameHistoryProvider);
      }
    } finally {
      if (mounted) {
        setState(() => _isMutating = false);
      }
    }
  }

  Future<void> _clear() async {
    setState(() => _isMutating = true);
    try {
      await ref.read(clearHistoryUseCaseProvider)();
      if (mounted) {
        ref.invalidate(gameHistoryProvider);
      }
    } finally {
      if (mounted) {
        setState(() => _isMutating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(gameHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: history.when(
        data: (records) {
          if (records.isEmpty) {
            return _EmptyHistory(onBack: () => context.go('/'));
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
            onClear: _clear,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            const Center(child: Text('Unable to load game history.')),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.records,
    required this.isMutating,
    required this.onDelete,
    required this.onClear,
  });

  final List<GameRecord> records;
  final bool isMutating;
  final Future<void> Function(String id) onDelete;
  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.space16),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            key: const Key('clear-history'),
            onPressed: isMutating ? null : onClear,
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Clear history'),
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        for (final record in records)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space8),
            child: Card(
              child: ListTile(
                title: Text(switch (record.winnerName) {
                  final winnerName? => '$winnerName won',
                  null => 'Draw',
                }),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record.playerOneName} vs ${record.playerTwoName} '
                      '· ${record.moveCount} moves',
                    ),
                    Text(
                      'Completed ${localizations.formatShortDate(record.completedAt.toLocal())} '
                      'at ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(record.completedAt.toLocal()))}',
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: IconButton(
                  key: Key('delete-${record.id}'),
                  tooltip: 'Delete game',
                  onPressed: isMutating ? null : () => onDelete(record.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 48),
            const SizedBox(height: AppSpacing.space12),
            Text(
              'No completed games yet.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.space16),
            TextButton(onPressed: onBack, child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}
