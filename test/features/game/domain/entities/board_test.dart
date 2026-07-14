import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/entities/board.dart';
import 'package:xo_arena/features/game/domain/entities/game_move_exception.dart';

void main() {
  test('requires exactly nine cells', () {
    expect(
      () => Board(cells: const [null]),
      throwsA(
        isA<ArgumentError>()
            .having((error) => error.name, 'name', 'cells.length')
            .having((error) => error.invalidValue, 'invalidValue', 1),
      ),
    );
  });

  test('places a mark without mutating original board', () {
    final initial = Board.empty();

    final next = initial.placeMark(4, GameMark.x);

    expect(initial.cells[4], isNull);
    expect(next.cells[4], GameMark.x);
    expect(next.availableMoves, isNot(contains(4)));
    expect(next.moveCount, 1);
  });

  test('copies provided cells to prevent external mutation', () {
    final cells = List<GameMark?>.filled(9, null);
    final board = Board(cells: cells);

    cells[0] = GameMark.x;

    expect(board.cells[0], isNull);
  });

  test('rejects positions outside board', () {
    expect(
      () => Board.empty().placeMark(9, GameMark.x),
      throwsA(
        isA<GameMoveException>().having(
          (error) => error.reason,
          'reason',
          GameMoveFailure.outOfBounds,
        ),
      ),
    );
  });

  test('rejects occupied positions', () {
    final board = Board.empty().placeMark(4, GameMark.x);

    expect(
      () => board.placeMark(4, GameMark.o),
      throwsA(
        isA<GameMoveException>().having(
          (error) => error.reason,
          'reason',
          GameMoveFailure.occupied,
        ),
      ),
    );
  });
}
