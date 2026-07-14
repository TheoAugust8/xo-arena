import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/core/design_system/components/app_icon_control.dart';
import 'package:xo_arena/core/design_system/components/app_logo.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';
import 'package:xo_arena/shared/settings/presentation/settings_ui.dart';
import 'package:xo_arena/shared/settings/presentation/widgets/settings_sheet.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record_stats.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(gameRecordsProvider);
    final preferences = ref.watch(settingsProvider);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final usesScroll =
                constraints.maxHeight < 680 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.3;
            final content = _HomeContent(
              history: history,
              preferences: preferences,
              disableAnimations: disableAnimations,
              fillsAvailableHeight: !usesScroll,
              onSettings: () => _showSettings(context, ref),
              onDifficultyChanged: (value) => _guardPersistence(
                context,
                ref.read(settingsProvider.notifier).setDifficulty(value),
              ),
              onPlay: () => context.go('/game'),
              onHistory: () => context.go('/history'),
              onRetryHistory: () => ref.invalidate(gameRecordsProvider),
            );

            if (usesScroll) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space20,
                  vertical: AppSpacing.space12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: content,
                  ),
                ),
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space20,
                    ),
                    child: content,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showSettings(BuildContext context, WidgetRef ref) {
    return showSettingsOverlay(
      context: context,
      builder: (sheetContext) => Consumer(
        builder: (context, sheetRef, _) {
          return SettingsSheet(
            theme: sheetRef.watch(settingsProvider).theme,
            settings: sheetRef.watch(settingsProvider),
            onThemeChanged: (value) => _guardPersistence(
              sheetContext,
              sheetRef.read(settingsProvider.notifier).setTheme(value),
            ),
            onDifficultyChanged: (value) => _guardPersistence(
              sheetContext,
              sheetRef.read(settingsProvider.notifier).setDifficulty(value),
            ),
            onSkinChanged: (value) => _guardPersistence(
              sheetContext,
              sheetRef.read(settingsProvider.notifier).setSkin(value),
            ),
            onSoundEnabledChanged: (value) => _guardPersistence(
              sheetContext,
              sheetRef.read(settingsProvider.notifier).setSoundEnabled(value),
            ),
            onClose: () => Navigator.of(sheetContext).pop(),
          );
        },
      ),
    );
  }

  Future<void> _guardPersistence(
    BuildContext context,
    Future<void> operation,
  ) async {
    try {
      await operation;
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to save settings.')));
    }
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.history,
    required this.preferences,
    required this.disableAnimations,
    required this.fillsAvailableHeight,
    required this.onSettings,
    required this.onDifficultyChanged,
    required this.onPlay,
    required this.onHistory,
    required this.onRetryHistory,
  });

  final AsyncValue<List<GameRecord>> history;
  final AppSettings preferences;
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
          selected: preferences.difficulty,
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

class _Reveal extends StatelessWidget {
  const _Reveal({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: enabled ? 0 : 1, end: 1),
      duration: enabled ? const Duration(milliseconds: 400) : Duration.zero,
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0, 1),
        child: Transform.scale(scale: 0.82 + value * 0.18, child: child),
      ),
      child: child,
    );
  }
}
