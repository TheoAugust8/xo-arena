import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

enum GameOutcome { playerOneWin, playerTwoWin, draw }

final class GameRecord {
  factory GameRecord({
    required String id,
    required String playerOneName,
    required String playerTwoName,
    required GameOutcome outcome,
    required int moveCount,
    required DateTime completedAt,
    required GameDifficulty difficulty,
    required GameSymbolSkin skin,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be blank');
    }
    if (playerOneName.trim().isEmpty) {
      throw ArgumentError.value(
        playerOneName,
        'playerOneName',
        'must not be blank',
      );
    }
    if (playerTwoName.trim().isEmpty) {
      throw ArgumentError.value(
        playerTwoName,
        'playerTwoName',
        'must not be blank',
      );
    }
    if (moveCount < 5 || moveCount > 9) {
      throw ArgumentError.value(moveCount, 'moveCount', 'must be from 5 to 9');
    }
    return GameRecord._(
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

  const GameRecord._({
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
  final int moveCount;
  final DateTime completedAt;
  final GameDifficulty difficulty;
  final GameSymbolSkin skin;

  GameRecord copyWith({
    String? id,
    String? playerOneName,
    String? playerTwoName,
    GameOutcome? outcome,
    int? moveCount,
    DateTime? completedAt,
    GameDifficulty? difficulty,
    GameSymbolSkin? skin,
  }) {
    return GameRecord(
      id: id ?? this.id,
      playerOneName: playerOneName ?? this.playerOneName,
      playerTwoName: playerTwoName ?? this.playerTwoName,
      outcome: outcome ?? this.outcome,
      moveCount: moveCount ?? this.moveCount,
      completedAt: completedAt ?? this.completedAt,
      difficulty: difficulty ?? this.difficulty,
      skin: skin ?? this.skin,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GameRecord &&
            id == other.id &&
            playerOneName == other.playerOneName &&
            playerTwoName == other.playerTwoName &&
            outcome == other.outcome &&
            moveCount == other.moveCount &&
            completedAt == other.completedAt &&
            difficulty == other.difficulty &&
            skin == other.skin;
  }

  @override
  int get hashCode => Object.hash(
    id,
    playerOneName,
    playerTwoName,
    outcome,
    moveCount,
    completedAt,
    difficulty,
    skin,
  );

  @override
  String toString() {
    return 'GameRecord(id: $id, playerOneName: $playerOneName, '
        'playerTwoName: $playerTwoName, outcome: $outcome, '
        'moveCount: $moveCount, completedAt: $completedAt, '
        'difficulty: $difficulty, skin: $skin)';
  }
}
