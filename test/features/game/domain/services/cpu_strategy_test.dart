import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/entities/board.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/domain/services/cpu_strategy.dart';

void main() {
  test('hard strategy takes immediate winning move', () {
    final game = _gameAfter([3, 0, 4, 1, 8]);

    expect(const MinimaxCpuStrategy().chooseMove(game), 2);
  });

  test('medium strategy blocks immediate player win', () {
    final game = _gameAfter([0, 3, 1]);

    expect(const MediumCpuStrategy().chooseMove(game), 2);
  });

  test('easy strategy never chooses an occupied cell', () {
    final game = _gameAfter([0, 2, 3, 5, 7]);

    for (var attempt = 0; attempt < 20; attempt++) {
      expect([1, 4, 6, 8], contains(EasyCpuStrategy().chooseMove(game)));
    }
  });

  test('hard strategy uses stable priority when scores tie', () {
    final game = _gameAfter([4]);

    expect(const MinimaxCpuStrategy().chooseMove(game), 0);
  });

  test('easy strategy can be deterministic in tests', () {
    final game = _gameAfter([0]);

    expect(
      EasyCpuStrategy(Random(42)).chooseMove(game),
      EasyCpuStrategy(Random(42)).chooseMove(game),
    );
  });

  test('minimax uses player mapping instead of fixed symbols', () {
    final game = _gameAfter(
      [3, 0, 4, 1, 8],
      playerMarks: const {
        GamePlayer.human: GameMark.o,
        GamePlayer.cpu: GameMark.x,
      },
    );

    expect(const MinimaxCpuStrategy().chooseMove(game), 2);
  });
}

Game _gameAfter(
  List<int> moves, {
  Map<GamePlayer, GameMark> playerMarks = const {
    GamePlayer.human: GameMark.x,
    GamePlayer.cpu: GameMark.o,
  },
}) {
  var game = Game.initial(playerMarks: playerMarks);
  for (final move in moves) {
    game = game.applyMove(by: game.currentPlayer, index: move);
  }
  expect(game.status, GameStatus.active);
  expect(game.currentPlayer, GamePlayer.cpu);
  return game;
}
