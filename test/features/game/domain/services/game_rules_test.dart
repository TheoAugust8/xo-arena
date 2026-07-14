import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/entities/board.dart';
import 'package:xo_arena/features/game/domain/services/game_rules.dart';

void main() {
  for (final line in GameRules.winningLines) {
    test('detects winning line $line', () {
      final cells = List<GameMark?>.filled(9, null);
      for (final index in line) {
        cells[index] = GameMark.x;
      }

      final result = GameRules.evaluate(Board(cells: cells));

      expect(result.winningMark, GameMark.x);
      expect(result.winningIndexes, line);
      expect(result.isDraw, isFalse);
    });
  }

  test('keeps partial board active', () {
    final result = GameRules.evaluate(
      Board(
        cells: const [
          GameMark.x,
          GameMark.o,
          null,
          null,
          GameMark.x,
          null,
          null,
          null,
          null,
        ],
      ),
    );

    expect(result.winningMark, isNull);
    expect(result.isDraw, isFalse);
    expect(result.winningIndexes, isEmpty);
  });

  test('evaluates full winning board as win', () {
    final result = GameRules.evaluate(
      Board(
        cells: const [
          GameMark.x,
          GameMark.o,
          GameMark.o,
          GameMark.o,
          GameMark.x,
          GameMark.x,
          GameMark.o,
          GameMark.x,
          GameMark.x,
        ],
      ),
    );

    expect(result.winningMark, GameMark.x);
    expect(result.winningIndexes, [0, 4, 8]);
    expect(result.isDraw, isFalse);
  });

  test('evaluates draw only on full board without winner', () {
    final result = GameRules.evaluate(
      Board(
        cells: const [
          GameMark.x,
          GameMark.o,
          GameMark.x,
          GameMark.x,
          GameMark.o,
          GameMark.o,
          GameMark.o,
          GameMark.x,
          GameMark.x,
        ],
      ),
    );

    expect(result.winningMark, isNull);
    expect(result.isDraw, isTrue);
    expect(result.winningIndexes, isEmpty);
  });
}
