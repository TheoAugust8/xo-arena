import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/entities/board.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/domain/entities/game_move_exception.dart';

void main() {
  test('starts active with Human playing X', () {
    final game = Game.initial();

    expect(game.board, Board.empty());
    expect(game.currentPlayer, GamePlayer.human);
    expect(game.markFor(GamePlayer.human), GameMark.x);
    expect(game.markFor(GamePlayer.cpu), GameMark.o);
    expect(game.status, GameStatus.active);
    expect(game.winner, isNull);
    expect(game.winningIndexes, isEmpty);
  });

  test('applies current player mark and alternates active turn', () {
    final game = Game.initial();

    final next = game.applyMove(by: GamePlayer.human, index: 4);

    expect(next.board.cells[4], GameMark.x);
    expect(next.currentPlayer, GamePlayer.cpu);
    expect(next.playerAt(4), GamePlayer.human);
  });

  test('rejects move from wrong player', () {
    expect(
      () => Game.initial().applyMove(by: GamePlayer.cpu, index: 4),
      throwsA(
        isA<GameMoveException>().having(
          (error) => error.reason,
          'reason',
          GameMoveFailure.wrongPlayer,
        ),
      ),
    );
  });

  test('maps winning mark back to player identity', () {
    var game = Game.initial();
    for (final move in const [
      (GamePlayer.human, 0),
      (GamePlayer.cpu, 3),
      (GamePlayer.human, 1),
      (GamePlayer.cpu, 4),
      (GamePlayer.human, 2),
    ]) {
      game = game.applyMove(by: move.$1, index: move.$2);
    }

    expect(game.status, GameStatus.won);
    expect(game.winner, GamePlayer.human);
    expect(game.winningIndexes, [0, 1, 2]);
    expect(game.currentPlayer, GamePlayer.human);
  });

  test('evaluates full winning board as win instead of draw', () {
    var game = Game.initial();
    for (final move in const [
      (GamePlayer.human, 0),
      (GamePlayer.cpu, 1),
      (GamePlayer.human, 4),
      (GamePlayer.cpu, 2),
      (GamePlayer.human, 5),
      (GamePlayer.cpu, 3),
      (GamePlayer.human, 6),
      (GamePlayer.cpu, 7),
      (GamePlayer.human, 8),
    ]) {
      game = game.applyMove(by: move.$1, index: move.$2);
    }

    expect(game.status, GameStatus.won);
    expect(game.winner, GamePlayer.human);
    expect(game.winningIndexes, [0, 4, 8]);
  });

  test('evaluates a completed game without winner as draw', () {
    var game = Game.initial();
    for (final move in const [0, 1, 2, 4, 3, 5, 7, 6, 8]) {
      game = game.applyMove(by: game.currentPlayer, index: move);
    }

    expect(game.status, GameStatus.draw);
    expect(game.winner, isNull);
    expect(game.winningIndexes, isEmpty);
    expect(game.currentPlayer, GamePlayer.human);
  });

  test('rejects moves after completion', () {
    var game = Game.initial();
    for (final move in const [
      (GamePlayer.human, 0),
      (GamePlayer.cpu, 3),
      (GamePlayer.human, 1),
      (GamePlayer.cpu, 4),
      (GamePlayer.human, 2),
    ]) {
      game = game.applyMove(by: move.$1, index: move.$2);
    }

    expect(
      () => game.applyMove(by: GamePlayer.human, index: 5),
      throwsA(
        isA<GameMoveException>().having(
          (error) => error.reason,
          'reason',
          GameMoveFailure.gameComplete,
        ),
      ),
    );
  });

  test('supports player identity independent from mark', () {
    final game = Game.initial(
      playerMarks: const {
        GamePlayer.human: GameMark.o,
        GamePlayer.cpu: GameMark.x,
      },
    ).applyMove(by: GamePlayer.human, index: 0);

    expect(game.board.cells[0], GameMark.o);
    expect(game.playerAt(0), GamePlayer.human);
  });

  test('copies player mapping to prevent external mutation', () {
    final playerMarks = <GamePlayer, GameMark>{
      GamePlayer.human: GameMark.o,
      GamePlayer.cpu: GameMark.x,
    };
    final game = Game.initial(playerMarks: playerMarks);

    playerMarks[GamePlayer.human] = GameMark.x;

    expect(game.markFor(GamePlayer.human), GameMark.o);
    expect(game.markFor(GamePlayer.cpu), GameMark.x);
  });

  for (final invalidMapping in [
    const {GamePlayer.human: GameMark.x},
    const {GamePlayer.human: GameMark.x, GamePlayer.cpu: GameMark.x},
  ]) {
    test('rejects incomplete or duplicate player mapping', () {
      expect(
        () => Game.initial(playerMarks: invalidMapping),
        throwsArgumentError,
      );
    });
  }
}
