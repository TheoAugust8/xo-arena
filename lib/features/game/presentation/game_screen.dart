import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xo_arena/app/notifiers/app_theme_notifier.dart';
import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/features/game/domain/game_round.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_notifier.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_state.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_cell.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_score.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_settings_sheet.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_status_badge.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_symbol.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final state = ref.watch(gameProvider);
    final themeMode = ref.watch(appThemeProvider);
    final themeNotifier = ref.read(appThemeProvider.notifier);
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
                onSettingsPressed: () => _showSettings(
                  context,
                  notifier,
                  state,
                  themeMode,
                  themeNotifier,
                ),
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
                  notifier: notifier,
                );
              }

              final compact = constraints.maxHeight < 720;
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

  void _showSettings(
    BuildContext context,
    GameNotifier notifier,
    GameState state,
    ThemeMode themeMode,
    AppThemeNotifier themeNotifier,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: GameSettingsSheet(
          themeMode: themeMode,
          difficulty: state.difficulty,
          skin: state.skin,
          onThemeModeChanged: themeNotifier.setThemeMode,
          onDifficultyChanged: notifier.setDifficulty,
          onSkinChanged: notifier.setSkin,
        ),
      ),
    );
  }
}

class _PortraitGameContent extends StatelessWidget {
  const _PortraitGameContent({
    required this.header,
    required this.state,
    required this.notifier,
    required this.compact,
  });

  final Widget header;
  final GameState state;
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
          skin: state.skin,
        ),
        SizedBox(height: compact ? AppSpacing.space12 : AppSpacing.space24),
        const _MatchDivider(),
        SizedBox(height: compact ? AppSpacing.space8 : AppSpacing.space16),
        _GameBoard(state: state, notifier: notifier),
        SizedBox(height: compact ? AppSpacing.space8 : AppSpacing.space16),
        _DifficultyBadge(difficulty: state.difficulty),
        SizedBox(height: compact ? AppSpacing.space8 : AppSpacing.space16),
        _RestartButton(onPressed: notifier.restart),
      ],
    );
  }
}

class _LandscapeGameContent extends StatelessWidget {
  const _LandscapeGameContent({
    required this.header,
    required this.state,
    required this.notifier,
  });

  final Widget header;
  final GameState state;
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
                  child: _GameBoard(state: state, notifier: notifier),
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
                        skin: state.skin,
                      ),
                      _DifficultyBadge(difficulty: state.difficulty),
                      _RestartButton(onPressed: notifier.restart),
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
  const _GameHeader({required this.onSettingsPressed});

  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'XO',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: tokens.primary),
              ),
              Text(
                'XO ARENA',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
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

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
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
  const _GameBoard({required this.state, required this.notifier});

  final GameState state;
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
                skin: state.skin,
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
  const _DifficultyBadge({required this.difficulty});

  final GameDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface2,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space12,
          vertical: AppSpacing.space8,
        ),
        child: Text(
          difficulty.name.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
