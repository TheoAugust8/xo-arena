import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:xo_arena/core/constants/app_routes.dart';
import 'package:xo_arena/core/design_system/app_fonts.dart';
import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/core/design_system/components/app_icon_control.dart';
import 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';
import 'package:xo_arena/core/design_system/components/app_logo.dart';
import 'package:xo_arena/l10n/l10n.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/settings/presentation/settings_ui.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record_participants.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record_stats.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';

part 'widgets/clear_history_dialog.dart';
part 'widgets/history_header.dart';
part 'widgets/history_list.dart';
part 'widgets/history_summary.dart';
part 'widgets/history_card.dart';
part 'widgets/history_states.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  var _isMutating = false;

  Future<bool> _delete(String id) async {
    if (_isMutating) return false;
    setState(() => _isMutating = true);
    try {
      await ref.read(gameRecordRepositoryProvider).delete(id);
      if (!mounted) return false;
      ref.invalidate(gameRecordsProvider);
      return true;
    } on Object {
      if (!mounted) return false;
      _showMutationError(context.l10n.unableToDeleteMatch);
      return false;
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<void> _confirmClear() async {
    if (_isMutating) return;
    setState(() => _isMutating = true);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.72),
        builder: (context) => const _ClearHistoryDialog(),
      );
      if (!mounted || confirmed != true) return;
      await ref.read(gameRecordRepositoryProvider).clear();
      if (!mounted) return;
      ref.invalidate(gameRecordsProvider);
    } on Object {
      if (!mounted) return;
      _showMutationError(context.l10n.unableToClearHistory);
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
                  onBack: () => context.go(AppRoutes.home),
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
                        return _EmptyHistory(
                          onPlay: () => context.go(AppRoutes.game),
                        );
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
