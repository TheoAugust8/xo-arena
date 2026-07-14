import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

void main() {
  test('creates an immutable copy with a changed outcome', () {
    final record = GameRecord(
      id: 'game-1',
      playerOneName: 'X',
      playerTwoName: 'O',
      outcome: GameOutcome.playerOneWin,
      moveCount: 7,
      completedAt: DateTime.utc(2026, 7, 12),
      difficulty: GameDifficulty.hard,
      skin: GameSymbolSkin.classic,
    );

    expect(record.copyWith(outcome: GameOutcome.playerTwoWin).winnerName, 'O');
  });

  test('keeps game preference snapshots in domain entity', () {
    final record = GameRecord(
      id: 'game-2',
      playerOneName: 'You',
      playerTwoName: 'CPU',
      outcome: GameOutcome.playerOneWin,
      moveCount: 5,
      completedAt: DateTime.utc(2026, 7, 13),
      difficulty: GameDifficulty.medium,
      skin: GameSymbolSkin.basketball,
    );

    expect(record.difficulty, GameDifficulty.medium);
    expect(record.skin, GameSymbolSkin.basketball);
    expect(record.winnerName, 'You');
  });
}
