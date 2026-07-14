part of 'package:xo_arena/features/game/presentation/game_screen.dart';

class _PortraitGameContent extends StatelessWidget {
  const _PortraitGameContent({
    required this.header,
    required this.state,
    required this.difficulty,
    required this.skin,
    required this.notifier,
    required this.compact,
  });

  final Widget header;
  final GameState state;
  final GameDifficulty difficulty;
  final GameSymbolSkin skin;
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
          playerMark: _symbolMarkFor(state.game.markFor(GamePlayer.human)),
          cpuMark: _symbolMarkFor(state.game.markFor(GamePlayer.cpu)),
          skin: skin,
        ),
        SizedBox(height: compact ? AppSpacing.space12 : AppSpacing.space24),
        const _MatchDivider(),
        SizedBox(height: compact ? AppSpacing.space8 : AppSpacing.space16),
        _GameBoard(state: state, skin: skin, notifier: notifier),
        SizedBox(height: compact ? AppSpacing.space8 : AppSpacing.space16),
        _DifficultyBadge(
          difficulty: difficulty,
          isCpuThinking: state.isCpuThinking,
        ),
        SizedBox(height: compact ? AppSpacing.space8 : AppSpacing.space16),
        _RestartButton(
          onPressed: state.game.isComplete ? notifier.restart : null,
        ),
      ],
    );
  }
}

class _LandscapeGameContent extends StatelessWidget {
  const _LandscapeGameContent({
    required this.header,
    required this.state,
    required this.difficulty,
    required this.skin,
    required this.notifier,
  });

  final Widget header;
  final GameState state;
  final GameDifficulty difficulty;
  final GameSymbolSkin skin;
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
                    skin: skin,
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
                        playerMark: _symbolMarkFor(
                          state.game.markFor(GamePlayer.human),
                        ),
                        cpuMark: _symbolMarkFor(
                          state.game.markFor(GamePlayer.cpu),
                        ),
                        skin: skin,
                      ),
                      _DifficultyBadge(
                        difficulty: difficulty,
                        isCpuThinking: state.isCpuThinking,
                      ),
                      _RestartButton(
                        onPressed: state.game.isComplete
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
