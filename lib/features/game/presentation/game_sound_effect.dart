import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_state.dart';

GameSoundCue? gameSoundCueForTransition(GameState? previous, GameState next) {
  if (previous == null) return null;

  if (!previous.game.isComplete && next.game.isComplete) {
    return switch ((next.game.status, next.game.winner)) {
      (GameStatus.won, GamePlayer.human) => GameSoundCue.win,
      (GameStatus.won, GamePlayer.cpu) => GameSoundCue.loss,
      (GameStatus.draw, _) => GameSoundCue.draw,
      _ => null,
    };
  }

  for (var index = 0; index < next.game.board.cells.length; index++) {
    if (previous.game.board.cells[index] == null &&
        next.game.board.cells[index] != null) {
      return switch (next.game.playerAt(index)) {
        GamePlayer.human => GameSoundCue.playerMove,
        GamePlayer.cpu => GameSoundCue.cpuMove,
        null => null,
      };
    }
  }
  return null;
}
