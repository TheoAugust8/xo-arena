import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xo_arena/features/game/domain/entities/game_round.dart';

part 'game_state.freezed.dart';

@freezed
abstract class GameState with _$GameState {
  const factory GameState({
    required GameRound round,
    required bool isCpuThinking,
    required int playerScore,
    required int cpuScore,
    required bool historySaveFailed,
  }) = _GameState;

  factory GameState.initial() => GameState(
    round: GameRound.initial(),
    isCpuThinking: false,
    playerScore: 0,
    cpuScore: 0,
    historySaveFailed: false,
  );
}
