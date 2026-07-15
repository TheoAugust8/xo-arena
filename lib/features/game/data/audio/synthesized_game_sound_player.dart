import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'package:xo_arena/features/game/application/ports/game_sound_player.dart';

final class SynthesizedGameSoundPlayer implements GameSoundPlayer {
  final _players = <GameSoundCue, AudioPlayer>{};
  final _preparation = <GameSoundCue, Future<void>>{};

  static final _audioContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
  );

  Future<void> _prepare(AudioPlayer player, GameSoundCue cue) async {
    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setAudioContext(_audioContext);
    await player.setSource(
      AssetSource('audio/${cue.name}.wav', mimeType: 'audio/wav'),
    );
  }

  AudioPlayer _playerFor(GameSoundCue cue) {
    return _players.putIfAbsent(
      cue,
      () => AudioPlayer(playerId: 'xo_arena_${cue.name}'),
    );
  }

  Future<void> _preparationFor(GameSoundCue cue) {
    return _preparation.putIfAbsent(cue, () => _prepare(_playerFor(cue), cue));
  }

  void _discardFailedPreparation(GameSoundCue cue, Future<void> preparation) {
    if (identical(_preparation[cue], preparation)) {
      unawaited(_preparation.remove(cue));
    }
  }

  @override
  Future<void> prepare() async {
    for (final cue in GameSoundCue.values) {
      final preparation = _preparationFor(cue);
      try {
        await preparation;
      } on Object {
        _discardFailedPreparation(cue, preparation);
      }
    }
  }

  @override
  Future<void> play(GameSoundCue cue) async {
    final player = _playerFor(cue);
    final preparation = _preparationFor(cue);

    try {
      await preparation;
      await player.stop();
      await player.resume();
    } on Object {
      _discardFailedPreparation(cue, preparation);
      // Sound must never interrupt gameplay.
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      try {
        await player.dispose();
      } on Object {
        // Audio cleanup failure must not affect application shutdown.
      }
    }
  }
}
