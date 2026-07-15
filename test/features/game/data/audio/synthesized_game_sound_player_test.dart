import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/data/audio/synthesized_game_sound_player.dart';
import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AudioplayersPlatformInterface originalPlatform;
  late GlobalAudioplayersPlatformInterface originalGlobalPlatform;
  late AudioCache originalCache;
  late Duration originalPreparationTimeout;
  late _RecordingAudioPlatform platform;

  setUp(() {
    originalPlatform = AudioplayersPlatformInterface.instance;
    originalGlobalPlatform = GlobalAudioplayersPlatformInterface.instance;
    originalCache = AudioCache.instance;
    originalPreparationTimeout = AudioPlayer.preparationTimeout;
    platform = _RecordingAudioPlatform();
    AudioplayersPlatformInterface.instance = platform;
    GlobalAudioplayersPlatformInterface.instance = _MemoryGlobalAudioPlatform();
    AudioCache.instance = _MemoryAudioCache();
    AudioPlayer.preparationTimeout = const Duration(milliseconds: 10);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });

  tearDown(() {
    AudioplayersPlatformInterface.instance = originalPlatform;
    GlobalAudioplayersPlatformInterface.instance = originalGlobalPlatform;
    AudioCache.instance = originalCache;
    AudioPlayer.preparationTimeout = originalPreparationTimeout;
    debugDefaultTargetPlatformOverride = null;
  });

  test('loads sound through a cross platform asset source', () async {
    final player = SynthesizedGameSoundPlayer();

    await player.play(GameSoundCue.playerMove);

    expect(platform.calls, contains('setSourceUrl'));
    expect(platform.calls, isNot(contains('setSourceBytes')));
    await player.dispose();
  });

  test('prepares every cue before first gameplay interaction', () async {
    final player = SynthesizedGameSoundPlayer();

    await player.prepare();

    expect(
      platform.calls.where((call) => call == 'setSourceUrl'),
      hasLength(GameSoundCue.values.length),
    );
    expect(platform.calls, isNot(contains('resume')));
    await player.dispose();
  });

  test('bundles one WAV asset for every sound cue', () async {
    for (final cue in GameSoundCue.values) {
      final data = await rootBundle.load('assets/audio/${cue.name}.wav');

      expect(data.lengthInBytes, greaterThan(44));
    }
  });

  test('retries preparation after a transient source failure', () async {
    platform.failNextSource = true;
    final player = SynthesizedGameSoundPlayer();

    await player.play(GameSoundCue.cpuMove);
    await player.play(GameSoundCue.cpuMove);

    expect(
      platform.calls.where((call) => call == 'setSourceUrl'),
      hasLength(2),
    );
    expect(platform.calls.where((call) => call == 'resume'), hasLength(1));
    await player.dispose();
  });
}

final class _MemoryAudioCache extends AudioCache {
  @override
  Future<String> loadPath(String fileName) async => '/tmp/$fileName';
}

final class _MemoryGlobalAudioPlatform
    implements GlobalAudioplayersPlatformInterface {
  @override
  Future<void> emitGlobalError(String code, String message) async {}

  @override
  Future<void> emitGlobalLog(String message) async {}

  @override
  Stream<GlobalAudioEvent> getGlobalEventStream() => const Stream.empty();

  @override
  Future<void> init() async {}

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) async {}
}

final class _RecordingAudioPlatform extends AudioplayersPlatformInterface {
  final calls = <String>[];
  final _events = <String, StreamController<AudioEvent>>{};
  var failNextSource = false;

  @override
  Future<void> create(String playerId) async {
    calls.add('create');
    _events[playerId] = StreamController<AudioEvent>.broadcast();
  }

  @override
  Future<void> dispose(String playerId) async {
    calls.add('dispose');
    await _events.remove(playerId)?.close();
  }

  @override
  Future<void> emitError(String playerId, String code, String message) async {}

  @override
  Future<void> emitLog(String playerId, String message) async {}

  @override
  Future<int?> getCurrentPosition(String playerId) async => 0;

  @override
  Future<int?> getDuration(String playerId) async => 0;

  @override
  Stream<AudioEvent> getEventStream(String playerId) =>
      _events[playerId]!.stream;

  @override
  Future<void> pause(String playerId) async {}

  @override
  Future<void> release(String playerId) async {}

  @override
  Future<void> resume(String playerId) async => calls.add('resume');

  @override
  Future<void> seek(String playerId, Duration position) async {}

  @override
  Future<void> setAudioContext(
    String playerId,
    AudioContext audioContext,
  ) async {}

  @override
  Future<void> setBalance(String playerId, double balance) async {}

  @override
  Future<void> setPlaybackRate(String playerId, double playbackRate) async {}

  @override
  Future<void> setPlayerMode(String playerId, PlayerMode playerMode) async {}

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) async {}

  @override
  Future<void> setSourceBytes(
    String playerId,
    Uint8List bytes, {
    String? mimeType,
  }) async {
    calls.add('setSourceBytes');
    _prepared(playerId);
  }

  @override
  Future<void> setSourceUrl(
    String playerId,
    String url, {
    bool? isLocal,
    String? mimeType,
  }) async {
    calls.add('setSourceUrl');
    if (failNextSource) {
      failNextSource = false;
      throw StateError('transient source failure');
    }
    _prepared(playerId);
  }

  @override
  Future<void> setVolume(String playerId, double volume) async {}

  @override
  Future<void> stop(String playerId) async => calls.add('stop');

  void _prepared(String playerId) {
    scheduleMicrotask(
      () => _events[playerId]?.add(
        const AudioEvent(eventType: AudioEventType.prepared, isPrepared: true),
      ),
    );
  }
}
