import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/entities/game_round.dart';

void main() {
  test('rejects a board that does not contain exactly nine cells', () {
    expect(
      () => GameRound(
        cells: const [null],
        status: GameStatus.active,
        winningIndexes: const [],
      ),
      throwsA(
        isA<ArgumentError>()
            .having((error) => error.name, 'name', 'cells.length')
            .having((error) => error.invalidValue, 'invalidValue', 1),
      ),
    );
  });
}
