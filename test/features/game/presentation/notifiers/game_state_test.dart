import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/entities/game_round.dart';
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
    expect(updated.round, initial.round);
  });

  test('compares equivalent rounds by value', () {
    final first = GameRound.initial();
    final second = GameRound.initial();

    expect(first, second);
  });

  test('does not expose mutable round collections', () {
    final round = GameRound.initial();

    expect(() => round.cells[0] = GameMark.player, throwsUnsupportedError);
    expect(() => round.winningIndexes.add(0), throwsUnsupportedError);
  });
}
