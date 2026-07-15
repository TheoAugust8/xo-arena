enum GameSoundCue { playerMove, cpuMove, win, loss, draw }

abstract interface class GameSoundPlayer {
  Future<void> prepare();

  Future<void> play(GameSoundCue cue);
}
