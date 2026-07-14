import 'dart:io';

import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';

import 'game_sound_synthesizer.dart';

void main() {
  final output = Directory('assets/audio')..createSync(recursive: true);
  for (final cue in GameSoundCue.values) {
    File(
      '${output.path}/${cue.name}.wav',
    ).writeAsBytesSync(GameSoundSynthesizer.synthesize(cue));
  }
}
