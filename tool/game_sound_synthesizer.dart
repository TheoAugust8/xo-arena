import 'dart:math' as math;
import 'dart:typed_data';

import 'package:xo_arena/features/game/application/ports/game_sound_player.dart';

abstract final class GameSoundSynthesizer {
  static const sampleRate = 22050;

  static Uint8List synthesize(GameSoundCue cue) {
    final segments = switch (cue) {
      // Mobile web output can swallow sub 100 ms clips during startup latency.
      GameSoundCue.playerMove => const [_Tone(720, 0.18, 0.7)],
      GameSoundCue.cpuMove => const [_Tone(360, 0.2, 0.62)],
      GameSoundCue.win => const [
        _Tone(523.25, 0.11, 0.58),
        _Tone(659.25, 0.11, 0.62),
        _Tone(783.99, 0.22, 0.68),
      ],
      GameSoundCue.loss => const [
        _Tone(329.63, 0.14, 0.58),
        _Tone(246.94, 0.14, 0.54),
        _Tone(164.81, 0.24, 0.5),
      ],
      GameSoundCue.draw => const [
        _Tone(440, 0.13, 0.48),
        _Tone(0, 0.045, 0),
        _Tone(440, 0.18, 0.48),
      ],
    };

    final sampleCount = segments.fold<int>(
      0,
      (total, segment) =>
          total + (segment.durationSeconds * sampleRate).round(),
    );
    final wav = ByteData(44 + sampleCount * 2);
    _writeHeader(wav, sampleCount);

    var sampleIndex = 0;
    for (final segment in segments) {
      final segmentSamples = (segment.durationSeconds * sampleRate).round();
      for (var localIndex = 0; localIndex < segmentSamples; localIndex++) {
        final time = localIndex / sampleRate;
        final progress = localIndex / segmentSamples;
        final envelope = _envelope(progress);
        final fundamental = segment.frequency == 0
            ? 0.0
            : math.sin(2 * math.pi * segment.frequency * time);
        final harmonic = segment.frequency == 0
            ? 0.0
            : math.sin(4 * math.pi * segment.frequency * time) * 0.18;
        final normalized = ((fundamental + harmonic) * segment.gain * envelope)
            .clamp(-1.0, 1.0);
        wav.setInt16(
          44 + sampleIndex * 2,
          (normalized * 32767).round(),
          Endian.little,
        );
        sampleIndex++;
      }
    }

    return wav.buffer.asUint8List();
  }

  static double _envelope(double progress) {
    const attackEnd = 0.08;
    const releaseStart = 0.68;
    if (progress < attackEnd) return progress / attackEnd;
    if (progress > releaseStart) {
      return (1 - progress) / (1 - releaseStart);
    }
    return 1;
  }

  static void _writeHeader(ByteData wav, int sampleCount) {
    _writeAscii(wav, 0, 'RIFF');
    wav.setUint32(4, 36 + sampleCount * 2, Endian.little);
    _writeAscii(wav, 8, 'WAVE');
    _writeAscii(wav, 12, 'fmt ');
    wav.setUint32(16, 16, Endian.little);
    wav.setUint16(20, 1, Endian.little);
    wav.setUint16(22, 1, Endian.little);
    wav.setUint32(24, sampleRate, Endian.little);
    wav.setUint32(28, sampleRate * 2, Endian.little);
    wav.setUint16(32, 2, Endian.little);
    wav.setUint16(34, 16, Endian.little);
    _writeAscii(wav, 36, 'data');
    wav.setUint32(40, sampleCount * 2, Endian.little);
  }

  static void _writeAscii(ByteData data, int offset, String value) {
    for (var index = 0; index < value.length; index++) {
      data.setUint8(offset + index, value.codeUnitAt(index));
    }
  }
}

class _Tone {
  const _Tone(this.frequency, this.durationSeconds, this.gain);

  final double frequency;
  final double durationSeconds;
  final double gain;
}
