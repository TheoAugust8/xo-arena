import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_round.freezed.dart';

enum GameMark { player, cpu }

enum GameStatus { active, playerWon, cpuWon, draw }

@freezed
abstract class GameRound with _$GameRound {
  GameRound._() {
    if (cells.length != 9) {
      throw ArgumentError.value(cells.length, 'cells.length', 'must be 9');
    }
  }

  factory GameRound({
    required List<GameMark?> cells,
    required GameStatus status,
    required List<int> winningIndexes,
  }) = _GameRound;

  bool get isComplete => status != GameStatus.active;

  factory GameRound.initial() => GameRound(
    cells: [null, null, null, null, null, null, null, null, null],
    status: GameStatus.active,
    winningIndexes: [],
  );
}
