import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/services/game_rules.dart';
import 'package:xo_arena/features/game/domain/entities/game_round.dart';

void main() {
  group('evaluate', () {
    for (final line in GameRules.winningLines) {
      test('detects winning line $line', () {
        final cells = List<GameMark?>.filled(9, null);
        for (final index in line) {
          cells[index] = GameMark.player;
        }

        final result = GameRules.evaluate(cells);

        expect(result.status, GameStatus.playerWon);
        expect(result.winningIndexes, line);
      });
    }

    test('keeps a partial board active', () {
      final result = GameRules.evaluate([
        GameMark.player,
        GameMark.cpu,
        null,
        null,
        GameMark.player,
        null,
        null,
        null,
        null,
      ]);

      expect(result.status, GameStatus.active);
      expect(result.winningIndexes, isEmpty);
    });

    test('evaluates a full winning board as a win', () {
      final result = GameRules.evaluate([
        GameMark.player,
        GameMark.cpu,
        GameMark.cpu,
        GameMark.cpu,
        GameMark.player,
        GameMark.player,
        GameMark.cpu,
        GameMark.player,
        GameMark.player,
      ]);

      expect(result.status, GameStatus.playerWon);
      expect(result.winningIndexes, [0, 4, 8]);
    });
  });

  test('evaluates draw only on full board without winner', () {
    final result = GameRules.evaluate([
      GameMark.player,
      GameMark.cpu,
      GameMark.player,
      GameMark.player,
      GameMark.cpu,
      GameMark.cpu,
      GameMark.cpu,
      GameMark.player,
      GameMark.player,
    ]);

    expect(result.status, GameStatus.draw);
    expect(result.winningIndexes, isEmpty);
  });

  group('applyMove', () {
    test('applies and evaluates a valid move', () {
      final next = GameRules.applyMove(GameRound.initial(), 4, GameMark.player);

      expect(next.cells[4], GameMark.player);
      expect(next.status, GameStatus.active);
    });

    test('rejects a move outside the board', () {
      expect(
        () => GameRules.applyMove(GameRound.initial(), 9, GameMark.player),
        throwsA(
          isA<GameMoveException>().having(
            (error) => error.reason,
            'reason',
            GameMoveFailure.outOfBounds,
          ),
        ),
      );
    });

    test('rejects a move on an occupied cell', () {
      final round = GameRules.applyMove(
        GameRound.initial(),
        4,
        GameMark.player,
      );

      expect(
        () => GameRules.applyMove(round, 4, GameMark.cpu),
        throwsA(
          isA<GameMoveException>().having(
            (error) => error.reason,
            'reason',
            GameMoveFailure.occupied,
          ),
        ),
      );
    });

    test('rejects a move after game completion', () {
      var round = GameRound.initial();
      for (final index in [0, 3, 1, 4, 2]) {
        round = GameRules.applyMove(
          round,
          index,
          index == 3 || index == 4 ? GameMark.cpu : GameMark.player,
        );
      }

      expect(
        () => GameRules.applyMove(round, 5, GameMark.cpu),
        throwsA(
          isA<GameMoveException>().having(
            (error) => error.reason,
            'reason',
            GameMoveFailure.gameComplete,
          ),
        ),
      );
    });
  });
}
