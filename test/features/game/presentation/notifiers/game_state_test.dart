import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/entities/board.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_state.dart';

void main() {
  test('compares a copied presentation state by value', () {
    final state = GameState.initial();

    expect(state.copyWith(), state);
  });

  test('creates immutable state updates with copyWith', () {
    final initial = GameState.initial();
    final updated = initial.copyWith(isCpuThinking: true);

    expect(updated.isCpuThinking, isTrue);
    expect(initial.isCpuThinking, isFalse);
    expect(updated.game, initial.game);
  });

  test('compares equivalent games by value', () {
    final first = Game.initial();
    final second = Game.initial();

    expect(first, second);
  });

  test('does not expose mutable game collections', () {
    final game = Game.initial();

    expect(() => game.board.cells[0] = GameMark.x, throwsUnsupportedError);
    expect(
      () => game.playerMarks[GamePlayer.human] = GameMark.o,
      throwsUnsupportedError,
    );
  });
}
