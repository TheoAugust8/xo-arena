import 'package:xo_arena/features/game/domain/entities/game_move_exception.dart';

enum GameMark { x, o }

final class Board {
  Board({required List<GameMark?> cells})
    : _cells = List<GameMark?>.unmodifiable(cells) {
    if (cells.length != 9) {
      throw ArgumentError.value(cells.length, 'cells.length', 'must be 9');
    }
  }

  factory Board.empty() => Board(cells: List.filled(9, null));

  final List<GameMark?> _cells;

  List<GameMark?> get cells => _cells;

  List<int> get availableMoves => [
    for (var index = 0; index < cells.length; index++)
      if (cells[index] == null) index,
  ];

  int get moveCount => cells.whereType<GameMark>().length;

  Board placeMark(int index, GameMark mark) {
    if (index < 0 || index >= cells.length) {
      throw const GameMoveException(GameMoveFailure.outOfBounds);
    }
    if (cells[index] != null) {
      throw const GameMoveException(GameMoveFailure.occupied);
    }

    return Board(cells: [...cells]..[index] = mark);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Board) return false;
    for (var index = 0; index < cells.length; index++) {
      if (cells[index] != other.cells[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(cells);

  @override
  String toString() => 'Board(cells: $cells)';
}
