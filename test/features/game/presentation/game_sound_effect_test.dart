import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';
import 'package:xo_arena/features/game/domain/entities/game_round.dart';
import 'package:xo_arena/features/game/presentation/game_sound_effect.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_state.dart';

void main() {
  test('maps Human and CPU moves to distinct cues', () {
    final initial = GameState.initial();

    expect(
      gameSoundCueForTransition(
        initial,
        _state(
          cells: const [
            GameMark.player,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
          ],
        ),
      ),
      GameSoundCue.playerMove,
    );
    expect(
      gameSoundCueForTransition(
        initial,
        _state(
          cells: const [
            GameMark.cpu,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
          ],
        ),
      ),
      GameSoundCue.cpuMove,
    );
  });

  test('prioritizes round result over final placement cue', () {
    final previous = _state(
      cells: const [
        GameMark.player,
        GameMark.player,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
      ],
    );

    expect(
      gameSoundCueForTransition(
        previous,
        _state(
          cells: const [
            GameMark.player,
            GameMark.player,
            GameMark.player,
            null,
            null,
            null,
            null,
            null,
            null,
          ],
          status: GameStatus.playerWon,
        ),
      ),
      GameSoundCue.win,
    );
  });

  test('maps CPU win and draw to result cues', () {
    final previous = GameState.initial();

    expect(
      gameSoundCueForTransition(previous, _state(status: GameStatus.cpuWon)),
      GameSoundCue.loss,
    );
    expect(
      gameSoundCueForTransition(previous, _state(status: GameStatus.draw)),
      GameSoundCue.draw,
    );
  });

  test('does not emit sound for initialization or restart', () {
    final played = _state(
      cells: const [
        GameMark.player,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
      ],
    );

    expect(gameSoundCueForTransition(null, played), isNull);
    expect(gameSoundCueForTransition(played, GameState.initial()), isNull);
  });
}

GameState _state({
  List<GameMark?> cells = const [
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
  ],
  GameStatus status = GameStatus.active,
}) {
  return GameState.initial().copyWith(
    round: GameRound(cells: cells, status: status, winningIndexes: const []),
  );
}
