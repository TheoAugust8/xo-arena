import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record_stats.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

void main() {
  test('summarizes wins draws losses and rounded win rate', () {
    final records = [
      _record('1', GameOutcome.playerOneWin),
      _record('2', GameOutcome.playerOneWin),
      _record('3', GameOutcome.draw),
      _record('4', GameOutcome.playerTwoWin),
    ];

    expect(
      GameRecordStats.fromRecords(records),
      const GameRecordStats(wins: 2, draws: 1, losses: 1, winRate: 50),
    );
  });

  test('uses zero win rate for empty history', () {
    expect(
      GameRecordStats.fromRecords([]),
      const GameRecordStats(wins: 0, draws: 0, losses: 0, winRate: 0),
    );
  });

  test('creates an immutable copy with updated values', () {
    const stats = GameRecordStats(wins: 2, draws: 1, losses: 1, winRate: 50);

    final updated = stats.copyWith(wins: 3, winRate: 60);

    expect(
      updated,
      const GameRecordStats(wins: 3, draws: 1, losses: 1, winRate: 60),
    );
    expect(
      stats,
      const GameRecordStats(wins: 2, draws: 1, losses: 1, winRate: 50),
    );
  });
}

GameRecord _record(String id, GameOutcome outcome) => GameRecord(
  id: id,
  playerOneName: 'You',
  playerTwoName: 'CPU',
  outcome: outcome,
  moveCount: 7,
  completedAt: DateTime.utc(2026, 7, 13),
  difficulty: GameDifficulty.hard,
  skin: GameSymbolSkin.classic,
);
