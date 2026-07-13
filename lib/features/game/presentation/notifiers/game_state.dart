import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xo_arena/features/game/domain/game_round.dart';
import 'package:xo_arena/features/game/presentation/models/game_symbol_skin.dart';

part 'game_state.freezed.dart';

@freezed
abstract class GameState with _$GameState {
  const factory GameState({
    required GameRound round,
    required bool isCpuThinking,
    required GameDifficulty difficulty,
    required GameSymbolSkin skin,
    required int playerScore,
    required int cpuScore,
    required bool historySaveFailed,
  }) = _GameState;

  factory GameState.initial() => GameState(
    round: GameRound.initial(),
    isCpuThinking: false,
    difficulty: GameDifficulty.hard,
    skin: GameSymbolSkin.classic,
    playerScore: 0,
    cpuScore: 0,
    historySaveFailed: false,
  );
}
