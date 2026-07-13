import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_round.freezed.dart';

enum GameMark { player, cpu }

enum GameStatus { active, playerWon, cpuWon, draw }

enum GameDifficulty { easy, medium, hard }

@freezed
abstract class GameRound with _$GameRound {
  const GameRound._();

  const factory GameRound({
    @Assert('cells.length == 9') required List<GameMark?> cells,
    required GameStatus status,
    required List<int> winningIndexes,
  }) = _GameRound;

  bool get isComplete => status != GameStatus.active;

  factory GameRound.initial() => const GameRound(
    cells: [null, null, null, null, null, null, null, null, null],
    status: GameStatus.active,
    winningIndexes: [],
  );
}
