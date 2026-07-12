import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_record.freezed.dart';
part 'game_record.g.dart';

@freezed
abstract class GameRecord with _$GameRecord {
  const factory GameRecord({
    required String id,
    required String playerOneName,
    required String playerTwoName,
    required String winnerName,
    required int moveCount,
    required DateTime completedAt,
  }) = _GameRecord;

  factory GameRecord.fromJson(Map<String, dynamic> json) =>
      _$GameRecordFromJson(json);
}
