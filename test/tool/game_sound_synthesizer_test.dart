import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';

import '../../tool/game_sound_synthesizer.dart';

void main() {
  test('creates valid PCM WAV data for every game cue', () {
    for (final cue in GameSoundCue.values) {
      final bytes = GameSoundSynthesizer.synthesize(cue);
      final header = ByteData.sublistView(bytes);

      expect(ascii.decode(bytes.sublist(0, 4)), 'RIFF');
      expect(ascii.decode(bytes.sublist(8, 12)), 'WAVE');
      expect(header.getUint16(20, Endian.little), 1);
      expect(header.getUint16(22, Endian.little), 1);
      expect(header.getUint32(24, Endian.little), 22050);
      expect(header.getUint16(34, Endian.little), 16);
      expect(header.getUint32(40, Endian.little), bytes.length - 44);
      expect(bytes.skip(44), contains(isNot(0)));
    }
  });

  test('uses short sounds suitable for interaction feedback', () {
    for (final cue in GameSoundCue.values) {
      final bytes = GameSoundSynthesizer.synthesize(cue);
      final sampleCount = (bytes.length - 44) ~/ 2;
      final duration = sampleCount / GameSoundSynthesizer.sampleRate;

      expect(duration, lessThan(0.55));
    }
  });

  test('keeps move cues audible through mobile web startup latency', () {
    for (final cue in [GameSoundCue.playerMove, GameSoundCue.cpuMove]) {
      final bytes = GameSoundSynthesizer.synthesize(cue);
      final sampleCount = (bytes.length - 44) ~/ 2;
      final duration = sampleCount / GameSoundSynthesizer.sampleRate;

      expect(duration, greaterThanOrEqualTo(0.16));
    }
  });
}
