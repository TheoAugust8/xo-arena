import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/entities/board.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/domain/services/cpu_strategy.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';

void main() {
  test('hard strategy takes immediate winning move', () {
    final game = _gameAfter([3, 0, 4, 1, 8]);
    const strategy = MinimaxCpuStrategy(
      random: _FixedRandom(doubleValue: 0, intValue: 0),
      mistakeRate: 1,
    );

    expect(strategy.chooseMove(game), 2);
  });

  test('hard strategy blocks immediate player win despite imperfection', () {
    final game = _gameAfter([0, 3, 1]);
    const strategy = MinimaxCpuStrategy(
      random: _FixedRandom(doubleValue: 0, intValue: 0),
      mistakeRate: 1,
    );

    expect(strategy.chooseMove(game), 2);
  });

  test('medium strategy blocks immediate player win', () {
    final game = _gameAfter([0, 3, 1]);

    expect(const MediumCpuStrategy().chooseMove(game), 2);
  });

  test('medium strategy takes a win before blocking', () {
    final game = _gameAfter([3, 0, 4, 1, 8]);

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

    expect(const MinimaxCpuStrategy(mistakeRate: 0).chooseMove(game), 0);
  });

  test('hard strategy uses a ten percent imperfection threshold', () {
    final game = _gameAfter([4]);

    expect(
      const MinimaxCpuStrategy(
        random: _FixedRandom(doubleValue: 0.099, intValue: 0),
      ).chooseMove(game),
      1,
    );
    expect(
      const MinimaxCpuStrategy(
        random: _FixedRandom(doubleValue: 0.1, intValue: 0),
      ).chooseMove(game),
      0,
    );
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

    expect(const MinimaxCpuStrategy(mistakeRate: 0).chooseMove(game), 2);
  });

  test('hard strategy offers a reachable human win', () {
    const strategy = MinimaxCpuStrategy(
      random: _FixedRandom(doubleValue: 0, intValue: 0),
    );

    expect(_hasReachableHumanWin(Game.initial(), strategy), isTrue);
  });

  test('minimax core never loses when imperfections are disabled', () {
    const strategy = MinimaxCpuStrategy(mistakeRate: 0);
    var completedGames = 0;

    void exploreHumanMoves(Game game) {
      expect(game.currentPlayer, GamePlayer.human);

      for (final humanMove in game.board.availableMoves) {
        final afterHuman = game.applyMove(
          by: GamePlayer.human,
          index: humanMove,
        );
        if (afterHuman.isComplete) {
          completedGames++;
          expect(afterHuman.winner, isNot(GamePlayer.human));
          continue;
        }

        final cpuMove = strategy.chooseMove(afterHuman);
        expect(afterHuman.board.availableMoves, contains(cpuMove));
        final afterCpu = afterHuman.applyMove(
          by: GamePlayer.cpu,
          index: cpuMove,
        );
        if (afterCpu.isComplete) {
          completedGames++;
          expect(afterCpu.winner, isNot(GamePlayer.human));
          continue;
        }

        exploreHumanMoves(afterCpu);
      }
    }

    exploreHumanMoves(Game.initial());

    expect(completedGames, greaterThan(0));
  });

  test('factory selects strategy matching every difficulty', () {
    expect(
      CpuStrategyFactory.forDifficulty(GameDifficulty.easy),
      isA<EasyCpuStrategy>(),
    );
    expect(
      CpuStrategyFactory.forDifficulty(GameDifficulty.medium),
      isA<MediumCpuStrategy>(),
    );
    expect(
      CpuStrategyFactory.forDifficulty(GameDifficulty.hard),
      isA<MinimaxCpuStrategy>(),
    );
  });

  test('strategies reject a board without available moves', () {
    final completedGame = _gameAfterMoves([0, 1, 2, 4, 3, 5, 7, 6, 8]);

    for (final strategy in <CpuStrategy>[
      EasyCpuStrategy(Random(42)),
      const MediumCpuStrategy(),
      const MinimaxCpuStrategy(),
    ]) {
      expect(
        () => strategy.chooseMove(completedGame),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'No available CPU move.',
          ),
        ),
      );
    }
  });
}

Game _gameAfter(
  List<int> moves, {
  Map<GamePlayer, GameMark> playerMarks = const {
    GamePlayer.human: GameMark.x,
    GamePlayer.cpu: GameMark.o,
  },
}) {
  final game = _gameAfterMoves(moves, playerMarks: playerMarks);
  expect(game.status, GameStatus.active);
  expect(game.currentPlayer, GamePlayer.cpu);
  return game;
}

bool _hasReachableHumanWin(Game game, CpuStrategy strategy) {
  for (final humanMove in game.board.availableMoves) {
    final afterHuman = game.applyMove(by: GamePlayer.human, index: humanMove);
    if (afterHuman.winner == GamePlayer.human) return true;
    if (afterHuman.isComplete) continue;

    final cpuMove = strategy.chooseMove(afterHuman);
    final afterCpu = afterHuman.applyMove(by: GamePlayer.cpu, index: cpuMove);
    if (!afterCpu.isComplete && _hasReachableHumanWin(afterCpu, strategy)) {
      return true;
    }
  }
  return false;
}

final class _FixedRandom implements Random {
  const _FixedRandom({required this.doubleValue, required this.intValue});

  final double doubleValue;
  final int intValue;

  @override
  bool nextBool() => doubleValue >= 0.5;

  @override
  double nextDouble() => doubleValue;

  @override
  int nextInt(int max) => intValue % max;
}

Game _gameAfterMoves(
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
  return game;
}
