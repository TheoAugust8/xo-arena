import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';
import 'package:xo_arena/features/game/domain/entities/game_round.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_state.dart';

GameSoundCue? gameSoundCueForTransition(GameState? previous, GameState next) {
  if (previous == null) return null;

  if (previous.round.status != next.round.status && next.round.isComplete) {
    return switch (next.round.status) {
      GameStatus.playerWon => GameSoundCue.win,
      GameStatus.cpuWon => GameSoundCue.loss,
      GameStatus.draw => GameSoundCue.draw,
      GameStatus.active => null,
    };
  }

  for (var index = 0; index < next.round.cells.length; index++) {
    if (previous.round.cells[index] == null &&
        next.round.cells[index] != null) {
      return switch (next.round.cells[index]) {
        GameMark.player => GameSoundCue.playerMove,
        GameMark.cpu => GameSoundCue.cpuMove,
        null => null,
      };
    }
  }
  return null;
}
