import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';

void main() {
  test('creates an immutable copy with a changed outcome', () {
    final record = GameRecord(
      id: 'game-1',
      playerOneName: 'X',
      playerTwoName: 'O',
      outcome: GameOutcome.playerOneWin,
      moveCount: 7,
      completedAt: DateTime.utc(2026, 7, 12),
    );

    expect(record.copyWith(outcome: GameOutcome.playerTwoWin).winnerName, 'O');
  });

  test('migrates a legacy draw record', () {
    final record = GameRecord.fromJson({
      'id': 'legacy-draw',
      'playerOneName': 'X',
      'playerTwoName': 'O',
      'winnerName': 'Draw',
      'moveCount': 9,
      'completedAt': '2026-07-12T00:00:00.000Z',
    });

    expect(record.outcome, GameOutcome.draw);
    expect(record.winnerName, isNull);
  });
}
