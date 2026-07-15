import 'package:json_annotation/json_annotation.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

part 'game_record_dto.g.dart';

@JsonSerializable()
final class GameRecordDto {
  const GameRecordDto({
    required this.id,
    required this.playerOneName,
    required this.playerTwoName,
    required this.outcome,
    required this.moveCount,
    required this.completedAt,
    required this.difficulty,
    required this.skin,
  });

  final String id;
  final String playerOneName;
  final String playerTwoName;
  final GameOutcome outcome;
  @JsonKey(fromJson: _moveCountFromJson)
  final int moveCount;
  final DateTime completedAt;
  final GameDifficulty difficulty;
  final GameSymbolSkin skin;

  factory GameRecordDto.fromJson(Map<String, dynamic> json) =>
      _$GameRecordDtoFromJson(json);

  factory GameRecordDto.fromDomain(GameRecord record) {
    return GameRecordDto(
      id: record.id,
      playerOneName: record.playerOneName,
      playerTwoName: record.playerTwoName,
      outcome: record.outcome,
      moveCount: record.moveCount,
      completedAt: record.completedAt,
      difficulty: record.difficulty,
      skin: record.skin,
    );
  }

  Map<String, dynamic> toJson() => _$GameRecordDtoToJson(this);

  GameRecord toDomain() {
    return GameRecord(
      id: id,
      playerOneName: playerOneName,
      playerTwoName: playerTwoName,
      outcome: outcome,
      moveCount: moveCount,
      completedAt: completedAt,
      difficulty: difficulty,
      skin: skin,
    );
  }
}

int _moveCountFromJson(num value) {
  if (value is! int) {
    throw const FormatException('Game record move count must be an integer.');
  }
  return value;
}
