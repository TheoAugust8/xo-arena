import 'package:xo_arena/features/game/domain/entities/board.dart';

class GameEvaluation {
  const GameEvaluation({
    required this.winningMark,
    required this.winningIndexes,
    required this.isDraw,
  });

  final GameMark? winningMark;
  final List<int> winningIndexes;
  final bool isDraw;
}

abstract final class GameRules {
  static const winningLines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  static GameEvaluation evaluate(Board board) {
    for (final line in winningLines) {
      final mark = board.cells[line.first];
      if (mark != null && line.every((index) => board.cells[index] == mark)) {
        return GameEvaluation(
          winningMark: mark,
          winningIndexes: line,
          isDraw: false,
        );
      }
    }
    return GameEvaluation(
      winningMark: null,
      winningIndexes: const [],
      isDraw: board.availableMoves.isEmpty,
    );
  }
}
