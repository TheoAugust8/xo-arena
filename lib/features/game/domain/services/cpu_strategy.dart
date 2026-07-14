import 'dart:math';

import 'package:xo_arena/features/game/domain/entities/game_round.dart';
import 'package:xo_arena/features/game/domain/services/game_rules.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';

abstract interface class CpuStrategy {
  int chooseMove(List<GameMark?> cells);
}

abstract final class CpuStrategyFactory {
  static CpuStrategy forDifficulty(GameDifficulty difficulty) {
    return switch (difficulty) {
      GameDifficulty.easy => EasyCpuStrategy(),
      GameDifficulty.medium => const MediumCpuStrategy(),
      GameDifficulty.hard => const MinimaxCpuStrategy(),
    };
  }
}

final class EasyCpuStrategy extends _CpuStrategyBase {
  EasyCpuStrategy([Random? random]) : _random = random ?? Random();

  final Random _random;

  @override
  int chooseMove(List<GameMark?> cells) {
    final availableMoves = moves(cells);
    requireAvailableMove(availableMoves);
    return availableMoves[_random.nextInt(availableMoves.length)];
  }
}

final class MediumCpuStrategy extends _CpuStrategyBase {
  const MediumCpuStrategy();

  @override
  int chooseMove(List<GameMark?> cells) {
    final availableMoves = moves(cells);
    requireAvailableMove(availableMoves);
    return winningMove(cells, GameMark.cpu) ??
        winningMove(cells, GameMark.player) ??
        ordered(availableMoves).first;
  }
}

final class MinimaxCpuStrategy extends _CpuStrategyBase {
  const MinimaxCpuStrategy();

  @override
  int chooseMove(List<GameMark?> cells) {
    final availableMoves = moves(cells);
    requireAvailableMove(availableMoves);

    var bestScore = -100;
    var bestMove = ordered(availableMoves).first;
    for (final move in ordered(availableMoves)) {
      final next = [...cells]..[move] = GameMark.cpu;
      final score = _minimax(next, isCpuTurn: false, depth: 0);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  int _minimax(
    List<GameMark?> cells, {
    required bool isCpuTurn,
    required int depth,
  }) {
    final status = GameRules.evaluate(cells).status;
    if (status == GameStatus.cpuWon) return 10 - depth;
    if (status == GameStatus.playerWon) return depth - 10;
    if (status == GameStatus.draw) return 0;

    final scores = ordered(moves(cells)).map((move) {
      final next = [...cells]
        ..[move] = isCpuTurn ? GameMark.cpu : GameMark.player;
      return _minimax(next, isCpuTurn: !isCpuTurn, depth: depth + 1);
    });
    return isCpuTurn ? scores.reduce(max) : scores.reduce(min);
  }
}

abstract base class _CpuStrategyBase implements CpuStrategy {
  const _CpuStrategyBase();

  static const _priority = [4, 0, 2, 6, 8, 1, 3, 5, 7];

  List<int> moves(List<GameMark?> cells) => [
    for (var index = 0; index < cells.length; index++)
      if (cells[index] == null) index,
  ];

  Iterable<int> ordered(Iterable<int> availableMoves) =>
      _priority.where(availableMoves.contains);

  int? winningMove(List<GameMark?> cells, GameMark mark) {
    for (final move in ordered(moves(cells))) {
      final next = [...cells]..[move] = mark;
      final winningStatus = mark == GameMark.cpu
          ? GameStatus.cpuWon
          : GameStatus.playerWon;
      if (GameRules.evaluate(next).status == winningStatus) return move;
    }
    return null;
  }

  void requireAvailableMove(List<int> availableMoves) {
    if (availableMoves.isEmpty) {
      throw StateError('No available CPU move.');
    }
  }
}
