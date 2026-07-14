import 'package:xo_arena/features/game/domain/entities/game_round.dart';

class GameEvaluation {
  const GameEvaluation({required this.status, required this.winningIndexes});

  final GameStatus status;
  final List<int> winningIndexes;
}

enum GameMoveFailure { outOfBounds, occupied, gameComplete }

final class GameMoveException implements Exception {
  const GameMoveException(this.reason);

  final GameMoveFailure reason;
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

  static GameEvaluation evaluate(List<GameMark?> cells) {
    if (cells.length != 9) {
      throw ArgumentError.value(cells.length, 'cells.length', 'must be 9');
    }

    for (final line in winningLines) {
      final mark = cells[line.first];
      if (mark != null && line.every((index) => cells[index] == mark)) {
        return GameEvaluation(
          status: mark == GameMark.player
              ? GameStatus.playerWon
              : GameStatus.cpuWon,
          winningIndexes: line,
        );
      }
    }
    return GameEvaluation(
      status: cells.every((mark) => mark != null)
          ? GameStatus.draw
          : GameStatus.active,
      winningIndexes: const [],
    );
  }

  static GameRound applyMove(GameRound round, int index, GameMark mark) {
    if (round.isComplete) {
      throw const GameMoveException(GameMoveFailure.gameComplete);
    }
    if (index < 0 || index >= round.cells.length) {
      throw const GameMoveException(GameMoveFailure.outOfBounds);
    }
    if (round.cells[index] != null) {
      throw const GameMoveException(GameMoveFailure.occupied);
    }

    final cells = [...round.cells]..[index] = mark;
    final evaluation = evaluate(cells);
    return GameRound(
      cells: cells,
      status: evaluation.status,
      winningIndexes: evaluation.winningIndexes,
    );
  }
}
