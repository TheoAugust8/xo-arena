import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/cpu_strategy.dart';
import 'package:xo_arena/features/game/domain/game_round.dart';

void main() {
  test('hard strategy takes immediate winning move', () {
    final move = const MinimaxCpuStrategy().chooseMove([
      GameMark.cpu,
      GameMark.cpu,
      null,
      GameMark.player,
      GameMark.player,
      null,
      null,
      null,
      null,
    ]);

    expect(move, 2);
  });

  test('medium strategy blocks immediate player win', () {
    final move = const MediumCpuStrategy().chooseMove([
      GameMark.player,
      GameMark.player,
      null,
      GameMark.cpu,
      null,
      null,
      null,
      null,
      null,
    ]);

    expect(move, 2);
  });

  test('easy strategy never chooses an occupied cell', () {
    const cells = [
      GameMark.player,
      null,
      GameMark.cpu,
      GameMark.player,
      null,
      GameMark.cpu,
      null,
      GameMark.player,
      null,
    ];

    for (var attempt = 0; attempt < 20; attempt++) {
      expect([1, 4, 6, 8], contains(EasyCpuStrategy().chooseMove(cells)));
    }
  });

  test('hard strategy uses stable priority when scores tie', () {
    final move = const MinimaxCpuStrategy().chooseMove(
      List<GameMark?>.filled(9, null),
    );

    expect(move, 4);
  });

  test('easy strategy can be deterministic in tests', () {
    final cells = List<GameMark?>.filled(9, null);

    expect(
      EasyCpuStrategy(Random(42)).chooseMove(cells),
      EasyCpuStrategy(Random(42)).chooseMove(cells),
    );
  });
}
