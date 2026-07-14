part of 'package:xo_arena/features/game/presentation/game_screen.dart';

class _GameBoard extends StatelessWidget {
  const _GameBoard({
    required this.state,
    required this.skin,
    required this.notifier,
  });

  final GameState state;
  final GameSymbolSkin skin;
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
              final mark = state.game.board.cells[index];
              return GameCell(
                variant: _cellVariant(state, index),
                mark: mark == null ? null : _symbolMarkFor(mark),
                skin: skin,
                dimension: cellDimension,
                onPressed:
                    mark == null &&
                        !state.isCpuThinking &&
                        !state.game.isComplete
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
    if (state.game.winningIndexes.contains(index)) {
      return GameCellVariant.winning;
    }
    return switch (state.game.board.cells[index]) {
      GameMark.x => GameCellVariant.x,
      GameMark.o => GameCellVariant.o,
      null => GameCellVariant.empty,
    };
  }
}

GameSymbolMark _symbolMarkFor(GameMark mark) => switch (mark) {
  GameMark.x => GameSymbolMark.x,
  GameMark.o => GameSymbolMark.o,
};
