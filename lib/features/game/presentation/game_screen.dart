import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/core/design_system/components/app_icon_control.dart';
import 'package:xo_arena/features/game/domain/entities/game_round.dart';
import 'package:xo_arena/features/game/presentation/game_sound_effect.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_notifier.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_state.dart';
import 'package:xo_arena/features/game/presentation/providers/game_sound_provider.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_cell.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_score.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_status_badge.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';
import 'package:xo_arena/shared/settings/presentation/widgets/settings_sheet.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final state = ref.watch(gameProvider);
    final preferences = ref.watch(settingsProvider);
    ref.listen<GameState>(gameProvider, (previous, next) {
      if (!ref.read(settingsProvider).soundEnabled) return;
      final cue = gameSoundCueForTransition(previous, next);
      if (cue != null) {
        unawaited(ref.read(gameSoundPlayerProvider).play(cue));
      }
    });
    ref.listen(gameProvider.select((value) => value.historySaveFailed), (
      previous,
      next,
    ) {
      if (next && previous != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Game completed, but history could not be saved.'),
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final header = _GameHeader(
                onBackPressed: () => context.go('/'),
                onSettingsPressed: () => _showSettings(context, notifier),
              );
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              if (textScale > 1.3) {
                final contentWidth = constraints.maxWidth
                    .clamp(0, 360.0)
                    .toDouble();
                return SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: _PortraitGameContent(
                        header: header,
                        state: state,
                        preferences: preferences,
                        notifier: notifier,
                        compact: false,
                      ),
                    ),
                  ),
                );
              }
              if (constraints.maxWidth > constraints.maxHeight) {
                return _LandscapeGameContent(
                  header: header,
                  state: state,
                  preferences: preferences,
                  notifier: notifier,
                );
              }

              const regularPortraitMinHeight = 760.0;
              final compact = constraints.maxHeight < regularPortraitMinHeight;
              final nonBoardHeight = compact ? 376.0 : 380.0;
              final heightBoundWidth = constraints.maxHeight - nonBoardHeight;
              final contentWidth = heightBoundWidth
                  .clamp(144.0, constraints.maxWidth)
                  .clamp(0, 360.0)
                  .toDouble();
              return Center(
                child: SizedBox(
                  width: contentWidth,
                  child: _PortraitGameContent(
                    header: header,
                    state: state,
                    preferences: preferences,
                    notifier: notifier,
                    compact: compact,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, GameNotifier notifier) {
    showSettingsOverlay(
      context: context,
      builder: (sheetContext) => Consumer(
        builder: (context, sheetRef, _) => SettingsSheet(
          theme: sheetRef.watch(settingsProvider).theme,
          settings: sheetRef.watch(settingsProvider),
          onThemeChanged: (value) => _guardPersistence(
            sheetContext,
            sheetRef.read(settingsProvider.notifier).setTheme(value),
          ),
          onDifficultyChanged: (value) =>
              _guardPersistence(sheetContext, notifier.setDifficulty(value)),
          onSkinChanged: (value) =>
              _guardPersistence(sheetContext, notifier.setSkin(value)),
          onSoundEnabledChanged: (value) => _guardPersistence(
            sheetContext,
            sheetRef.read(settingsProvider.notifier).setSoundEnabled(value),
          ),
          onClose: () => Navigator.of(sheetContext).pop(),
        ),
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

class _PortraitGameContent extends StatelessWidget {
  const _PortraitGameContent({
    required this.header,
    required this.state,
    required this.preferences,
    required this.notifier,
    required this.compact,
  });

  final Widget header;
  final GameState state;
  final AppSettings preferences;
  final GameNotifier notifier;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        Divider(height: compact ? AppSpacing.space20 : 30),
        GameStatusBadge(variant: _statusVariantFor(state)),
        SizedBox(height: compact ? AppSpacing.space8 : AppSpacing.space16),
        GameScore(
          playerScore: state.playerScore,
          cpuScore: state.cpuScore,
          skin: preferences.skin,
        ),
        SizedBox(height: compact ? AppSpacing.space12 : AppSpacing.space24),
        const _MatchDivider(),
        SizedBox(height: compact ? AppSpacing.space8 : AppSpacing.space16),
        _GameBoard(state: state, preferences: preferences, notifier: notifier),
        SizedBox(height: compact ? AppSpacing.space8 : AppSpacing.space16),
        _DifficultyBadge(
          difficulty: preferences.difficulty,
          isCpuThinking: state.isCpuThinking,
        ),
        SizedBox(height: compact ? AppSpacing.space8 : AppSpacing.space16),
        _RestartButton(
          onPressed: state.round.isComplete ? notifier.restart : null,
        ),
      ],
    );
  }
}

class _LandscapeGameContent extends StatelessWidget {
  const _LandscapeGameContent({
    required this.header,
    required this.state,
    required this.preferences,
    required this.notifier,
  });

  final Widget header;
  final GameState state;
  final AppSettings preferences;
  final GameNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final panelDimension = constraints.maxHeight
            .clamp(144.0, (constraints.maxWidth - AppSpacing.space20) / 2)
            .clamp(0, 360.0)
            .toDouble();
        return Center(
          child: SizedBox(
            width: panelDimension * 2 + AppSpacing.space20,
            child: Row(
              children: [
                SizedBox.square(
                  dimension: panelDimension,
                  child: _GameBoard(
                    state: state,
                    preferences: preferences,
                    notifier: notifier,
                  ),
                ),
                const SizedBox(width: AppSpacing.space20),
                SizedBox(
                  width: panelDimension,
                  height: panelDimension,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      header,
                      GameStatusBadge(variant: _statusVariantFor(state)),
                      GameScore(
                        playerScore: state.playerScore,
                        cpuScore: state.cpuScore,
                        skin: preferences.skin,
                      ),
                      _DifficultyBadge(
                        difficulty: preferences.difficulty,
                        isCpuThinking: state.isCpuThinking,
                      ),
                      _RestartButton(
                        onPressed: state.round.isComplete
                            ? notifier.restart
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.onBackPressed,
    required this.onSettingsPressed,
  });

  final VoidCallback onBackPressed;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Row(
      children: [
        AppIconControl(
          key: const ValueKey('game_back_button'),
          tooltip: 'Back to Home',
          icon: Icons.chevron_left,
          visualSize: 36,
          iconSize: 20,
          onPressed: onBackPressed,
        ),
        const SizedBox(width: AppSpacing.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ARENA',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: tokens.primary,
                  fontSize: 9,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'XO ARENA',
                style: TextStyle(
                  fontFamily: 'Barlow Condensed',
                  color: tokens.foreground,
                  fontSize: 24,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        AppIconControl(
          key: const ValueKey('game_settings_button'),
          tooltip: 'Settings',
          icon: Icons.settings_outlined,
          visualSize: 40,
          iconSize: 18,
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }
}

class _MatchDivider extends StatelessWidget {
  const _MatchDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
          child: Text('MATCH', style: Theme.of(context).textTheme.labelMedium),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _RestartButton extends StatelessWidget {
  const _RestartButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        key: const ValueKey('game_new_game_button'),
        onPressed: onPressed,
        icon: const Icon(Icons.refresh, size: 16),
        label: const Text('NEW GAME'),
      ),
    );
  }
}

GameStatusVariant _statusVariantFor(GameState state) {
  if (state.isCpuThinking) return GameStatusVariant.cpu;
  return switch (state.round.status) {
    GameStatus.active => GameStatusVariant.player,
    GameStatus.playerWon => GameStatusVariant.playerWin,
    GameStatus.cpuWon => GameStatusVariant.cpuWin,
    GameStatus.draw => GameStatusVariant.draw,
  };
}

class _GameBoard extends StatelessWidget {
  const _GameBoard({
    required this.state,
    required this.preferences,
    required this.notifier,
  });

  final GameState state;
  final AppSettings preferences;
  final GameNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardDimension = constraints.maxWidth;
        final cellDimension = (boardDimension - AppSpacing.space16) / 3;

        return SizedBox.square(
          dimension: boardDimension,
          child: GridView.count(
            crossAxisCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            crossAxisSpacing: AppSpacing.space8,
            mainAxisSpacing: AppSpacing.space8,
            children: List.generate(9, (index) {
              final mark = state.round.cells[index];
              return GameCell(
                variant: _cellVariant(state, index),
                mark: mark == GameMark.player
                    ? GameSymbolMark.x
                    : mark == GameMark.cpu
                    ? GameSymbolMark.o
                    : null,
                skin: preferences.skin,
                dimension: cellDimension,
                onPressed:
                    mark == null &&
                        !state.isCpuThinking &&
                        !state.round.isComplete
                    ? () => notifier.play(index)
                    : null,
              );
            }),
          ),
        );
      },
    );
  }

  GameCellVariant _cellVariant(GameState state, int index) {
    if (state.round.winningIndexes.contains(index)) {
      return GameCellVariant.winning;
    }
    return switch (state.round.cells[index]) {
      GameMark.player => GameCellVariant.playerX,
      GameMark.cpu => GameCellVariant.cpuO,
      null => GameCellVariant.empty,
    };
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({
    required this.difficulty,
    required this.isCpuThinking,
  });

  final GameDifficulty difficulty;
  final bool isCpuThinking;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final color = switch (difficulty) {
      GameDifficulty.easy => tokens.win,
      GameDifficulty.medium => tokens.warn,
      GameDifficulty.hard => tokens.primary,
    };
    return Semantics(
      label: '${difficulty.name} difficulty',
      excludeSemantics: true,
      child: DecoratedBox(
        key: const ValueKey('game_difficulty_badge'),
        decoration: BoxDecoration(
          color: tokens.surface2,
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space12,
            vertical: 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GameActivityDot(color: color, size: 6, isPulsing: isCpuThinking),
              const SizedBox(width: 6),
              Text(
                difficulty.name.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: tokens.mutedForeground,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
