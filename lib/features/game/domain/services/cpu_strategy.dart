import 'dart:math';

import 'package:xo_arena/features/game/domain/entities/board.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/domain/services/game_rules.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';

abstract interface class CpuStrategy {
  int chooseMove(Game game);
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
  int chooseMove(Game game) {
    final availableMoves = game.board.availableMoves;
    requireAvailableMove(availableMoves);
    return availableMoves[_random.nextInt(availableMoves.length)];
  }
}

final class MediumCpuStrategy extends _CpuStrategyBase {
  const MediumCpuStrategy();

  @override
  int chooseMove(Game game) {
    final availableMoves = game.board.availableMoves;
    requireAvailableMove(availableMoves);
    return winningMove(game.board, game.markFor(GamePlayer.cpu)) ??
        winningMove(game.board, game.markFor(GamePlayer.human)) ??
        ordered(availableMoves).first;
  }
}

final class MinimaxCpuStrategy extends _CpuStrategyBase {
  const MinimaxCpuStrategy();

  @override
  int chooseMove(Game game) {
    final board = game.board;
    final cpuMark = game.markFor(GamePlayer.cpu);
    final humanMark = game.markFor(GamePlayer.human);
    final availableMoves = board.availableMoves;
    requireAvailableMove(availableMoves);

    var bestScore = -100;
    var bestMove = ordered(availableMoves).first;
    for (final move in ordered(availableMoves)) {
      final next = board.placeMark(move, cpuMark);
      final score = _minimax(
        next,
        cpuMark: cpuMark,
        humanMark: humanMark,
        isCpuTurn: false,
        depth: 0,
      );
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    return bestMove;
  }

  int _minimax(
    Board board, {
    required GameMark cpuMark,
    required GameMark humanMark,
    required bool isCpuTurn,
    required int depth,
  }) {
    final evaluation = GameRules.evaluate(board);
    if (evaluation.winningMark == cpuMark) return 10 - depth;
    if (evaluation.winningMark == humanMark) return depth - 10;
    if (evaluation.isDraw) return 0;

    final scores = ordered(board.availableMoves).map((move) {
      final next = board.placeMark(move, isCpuTurn ? cpuMark : humanMark);
      return _minimax(
        next,
        cpuMark: cpuMark,
        humanMark: humanMark,
        isCpuTurn: !isCpuTurn,
        depth: depth + 1,
      );
    });
    return isCpuTurn ? scores.reduce(max) : scores.reduce(min);
  }
}

abstract base class _CpuStrategyBase implements CpuStrategy {
  const _CpuStrategyBase();

  static const _priority = [4, 0, 2, 6, 8, 1, 3, 5, 7];

  Iterable<int> ordered(Iterable<int> availableMoves) =>
      _priority.where(availableMoves.contains);

  int? winningMove(Board board, GameMark mark) {
    for (final move in ordered(board.availableMoves)) {
      final next = board.placeMark(move, mark);
      if (GameRules.evaluate(next).winningMark == mark) return move;
    }
    return null;
  }

  void requireAvailableMove(List<int> availableMoves) {
    if (availableMoves.isEmpty) {
      throw StateError('No available CPU move.');
    }
  }
}
