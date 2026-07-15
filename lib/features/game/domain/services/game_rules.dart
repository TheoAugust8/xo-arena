import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:xo_arena/features/game/domain/entities/board.dart';

part 'game_rules.freezed.dart';

/// Exhaustive evaluation states prevent impossible draw and winner mixtures.
@freezed
sealed class GameEvaluation with _$GameEvaluation {
  const GameEvaluation._();

  const factory GameEvaluation.active() = ActiveGameEvaluation;

  const factory GameEvaluation.won({
    required GameMark mark,
    required List<int> winningIndexes,
  }) = WonGameEvaluation;

  const factory GameEvaluation.draw() = DrawGameEvaluation;

  GameMark? get winningMark => switch (this) {
    WonGameEvaluation(:final mark) => mark,
    ActiveGameEvaluation() || DrawGameEvaluation() => null,
  };

  List<int> get winningIndexes => switch (this) {
    WonGameEvaluation(:final winningIndexes) => winningIndexes,
    ActiveGameEvaluation() || DrawGameEvaluation() => const [],
  };

  bool get isDraw => this is DrawGameEvaluation;
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
        return GameEvaluation.won(mark: mark, winningIndexes: line);
      }
    }
    return board.availableMoves.isEmpty
        ? const GameEvaluation.draw()
        : const GameEvaluation.active();
  }
}
