import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

part 'game_record.freezed.dart';

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
    required GameDifficulty difficulty,
    required GameSymbolSkin skin,
  }) = _GameRecord;

  String? get winnerName => switch (outcome) {
    GameOutcome.playerOneWin => playerOneName,
    GameOutcome.playerTwoWin => playerTwoName,
    GameOutcome.draw => null,
  };
}
