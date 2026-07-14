import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';
import 'package:xo_arena/features/game/presentation/game_sound_effect.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_state.dart';

void main() {
  test('maps Human and CPU moves to distinct cues', () {
    final initial = GameState.initial();
    final afterHuman = _state([(GamePlayer.human, 0)]);
    final afterCpu = _state([(GamePlayer.human, 0), (GamePlayer.cpu, 4)]);

    expect(
      gameSoundCueForTransition(initial, afterHuman),
      GameSoundCue.playerMove,
    );
    expect(
      gameSoundCueForTransition(afterHuman, afterCpu),
      GameSoundCue.cpuMove,
    );
  });

  test('prioritizes result over final placement cue', () {
    final previous = _state([
      (GamePlayer.human, 0),
      (GamePlayer.cpu, 3),
      (GamePlayer.human, 1),
      (GamePlayer.cpu, 4),
    ]);
    final completed = _state([
      (GamePlayer.human, 0),
      (GamePlayer.cpu, 3),
      (GamePlayer.human, 1),
      (GamePlayer.cpu, 4),
      (GamePlayer.human, 2),
    ]);

    expect(gameSoundCueForTransition(previous, completed), GameSoundCue.win);
  });

  test('maps CPU win and draw to result cues', () {
    final beforeCpuWin = _state([
      (GamePlayer.human, 0),
      (GamePlayer.cpu, 4),
      (GamePlayer.human, 8),
      (GamePlayer.cpu, 2),
      (GamePlayer.human, 1),
    ]);
    final cpuWin = _state([
      (GamePlayer.human, 0),
      (GamePlayer.cpu, 4),
      (GamePlayer.human, 8),
      (GamePlayer.cpu, 2),
      (GamePlayer.human, 1),
      (GamePlayer.cpu, 6),
    ]);
    final beforeDraw = _state([
      (GamePlayer.human, 0),
      (GamePlayer.cpu, 1),
      (GamePlayer.human, 2),
      (GamePlayer.cpu, 4),
      (GamePlayer.human, 3),
      (GamePlayer.cpu, 5),
      (GamePlayer.human, 7),
      (GamePlayer.cpu, 6),
    ]);
    final draw = _state([
      (GamePlayer.human, 0),
      (GamePlayer.cpu, 1),
      (GamePlayer.human, 2),
      (GamePlayer.cpu, 4),
      (GamePlayer.human, 3),
      (GamePlayer.cpu, 5),
      (GamePlayer.human, 7),
      (GamePlayer.cpu, 6),
      (GamePlayer.human, 8),
    ]);

    expect(gameSoundCueForTransition(beforeCpuWin, cpuWin), GameSoundCue.loss);
    expect(gameSoundCueForTransition(beforeDraw, draw), GameSoundCue.draw);
  });

  test('does not emit sound for initialization or restart', () {
    final played = _state([(GamePlayer.human, 0)]);

    expect(gameSoundCueForTransition(null, played), isNull);
    expect(gameSoundCueForTransition(played, GameState.initial()), isNull);
  });
}

GameState _state(List<(GamePlayer, int)> moves) {
  var game = Game.initial();
  for (final move in moves) {
    game = game.applyMove(by: move.$1, index: move.$2);
  }
  return GameState.initial().copyWith(game: game);
}
