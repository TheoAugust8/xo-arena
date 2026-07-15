import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/data/models/game_record_dto.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

void main() {
  test('preserves existing JSON wire format', () {
    final record = _record();

    final json = GameRecordDto.fromDomain(record).toJson();

    expect(json, {
      'id': 'game-1',
      'playerOneName': 'You',
      'playerTwoName': 'CPU',
      'outcome': 'playerOneWin',
      'moveCount': 7,
      'completedAt': '2026-07-13T00:00:00.000Z',
      'difficulty': 'medium',
      'skin': 'basketball',
    });
    expect(GameRecordDto.fromJson(json).toDomain(), record);
  });

  for (final enumField in ['outcome', 'difficulty', 'skin']) {
    test('rejects unknown $enumField value', () {
      final json = GameRecordDto.fromDomain(_record()).toJson()
        ..[enumField] = 'unknown';

      expect(() => GameRecordDto.fromJson(json), throwsA(isA<ArgumentError>()));
    });
  }

  test('rejects invalid field types', () {
    final json = GameRecordDto.fromDomain(_record()).toJson()
      ..['moveCount'] = '7';

    expect(() => GameRecordDto.fromJson(json), throwsA(isA<TypeError>()));
  });

  test('rejects fractional move count', () {
    final json = GameRecordDto.fromDomain(_record()).toJson()
      ..['moveCount'] = 7.5;

    expect(() => GameRecordDto.fromJson(json), throwsA(isA<FormatException>()));
  });

  test('rejects invalid ISO 8601 date', () {
    final json = GameRecordDto.fromDomain(_record()).toJson()
      ..['completedAt'] = 'not-a-date';

    expect(() => GameRecordDto.fromJson(json), throwsA(isA<FormatException>()));
  });

  for (final invalid in [
    ('blank id', '', 'You', 'CPU', 7),
    ('blank first player', 'game-1', ' ', 'CPU', 7),
    ('blank second player', 'game-1', 'You', '', 7),
    ('too few moves', 'game-1', 'You', 'CPU', 4),
    ('too many moves', 'game-1', 'You', 'CPU', 10),
  ]) {
    test('rejects ${invalid.$1}', () {
      final dto = GameRecordDto(
        id: invalid.$2,
        playerOneName: invalid.$3,
        playerTwoName: invalid.$4,
        outcome: GameOutcome.playerOneWin,
        moveCount: invalid.$5,
        completedAt: DateTime.utc(2026, 7, 13),
        difficulty: GameDifficulty.medium,
        skin: GameSymbolSkin.basketball,
      );

      expect(dto.toDomain, throwsA(isA<ArgumentError>()));
    });
  }
}

GameRecord _record() => GameRecord(
  id: 'game-1',
  playerOneName: 'You',
  playerTwoName: 'CPU',
  outcome: GameOutcome.playerOneWin,
  moveCount: 7,
  completedAt: DateTime.utc(2026, 7, 13),
  difficulty: GameDifficulty.medium,
  skin: GameSymbolSkin.basketball,
);
