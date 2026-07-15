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

    expect(
      record.copyWith(outcome: GameOutcome.playerTwoWin).outcome,
      GameOutcome.playerTwoWin,
    );
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
  });

  test('rejects a blank record id', () {
    expect(() => _record(id: ' '), throwsArgumentError);
  });

  test('rejects blank participant names', () {
    expect(() => _record(playerOneName: ''), throwsArgumentError);
    expect(() => _record(playerTwoName: '  '), throwsArgumentError);
  });

  test('rejects move counts outside a completed game range', () {
    expect(() => _record(moveCount: 4), throwsArgumentError);
    expect(() => _record(moveCount: 10), throwsArgumentError);
  });

  test('copyWith preserves domain invariants', () {
    expect(() => _record().copyWith(moveCount: 4), throwsArgumentError);
  });
}

GameRecord _record({
  String id = 'game-1',
  String playerOneName = 'You',
  String playerTwoName = 'CPU',
  int moveCount = 7,
}) {
  return GameRecord(
    id: id,
    playerOneName: playerOneName,
    playerTwoName: playerTwoName,
    outcome: GameOutcome.playerOneWin,
    moveCount: moveCount,
    completedAt: DateTime.utc(2026, 7, 13),
    difficulty: GameDifficulty.medium,
    skin: GameSymbolSkin.classic,
  );
}
