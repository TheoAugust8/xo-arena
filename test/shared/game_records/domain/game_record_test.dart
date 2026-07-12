import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';

void main() {
  test('creates an immutable copy with a changed winner', () {
    final record = GameRecord(
      id: 'game-1',
      playerOneName: 'X',
      playerTwoName: 'O',
      winnerName: 'X',
      moveCount: 7,
      completedAt: DateTime.utc(2026, 7, 12),
    );

    expect(record.copyWith(winnerName: 'O').winnerName, 'O');
  });
}
