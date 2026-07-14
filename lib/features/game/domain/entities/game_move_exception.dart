enum GameMoveFailure { outOfBounds, occupied, gameComplete, wrongPlayer }

final class GameMoveException implements Exception {
  const GameMoveException(this.reason);

  final GameMoveFailure reason;
}
