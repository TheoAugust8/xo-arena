import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_record.freezed.dart';
part 'game_record.g.dart';

enum GameOutcome { playerOneWin, playerTwoWin, draw }

@freezed
abstract class GameRecord with _$GameRecord {
  const GameRecord._();

  const factory GameRecord({
    required String id,
    required String playerOneName,
    required String playerTwoName,
    required GameOutcome outcome,
    required int moveCount,
    required DateTime completedAt,
  }) = _GameRecord;

  String? get winnerName => switch (outcome) {
    GameOutcome.playerOneWin => playerOneName,
    GameOutcome.playerTwoWin => playerTwoName,
    GameOutcome.draw => null,
  };

  factory GameRecord.fromJson(Map<String, dynamic> json) =>
      _$GameRecordFromJson(_migrateLegacyRecord(json));
}

Map<String, dynamic> _migrateLegacyRecord(Map<String, dynamic> json) {
  final migratedJson = Map<String, dynamic>.of(json);
  migratedJson['outcome'] ??= _legacyOutcome(json).name;
  migratedJson.remove('winnerName');
  return migratedJson;
}

GameOutcome _legacyOutcome(Map<String, dynamic> json) {
  final winnerName = json['winnerName'] as String?;
  if (winnerName == null || winnerName.toLowerCase() == 'draw') {
    return GameOutcome.draw;
  }
  return winnerName == json['playerTwoName']
      ? GameOutcome.playerTwoWin
      : GameOutcome.playerOneWin;
}
