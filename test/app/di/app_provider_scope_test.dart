import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xo_arena/app/di/app_provider_scope.dart';
import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';
import 'package:xo_arena/features/game/presentation/providers/game_sound_provider.dart';
import 'package:xo_arena/shared/game_records/data/repositories/game_record_repository_impl.dart';
import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';
import 'package:xo_arena/shared/settings/data/repositories/settings_repository_impl.dart';
import 'package:xo_arena/shared/settings/domain/repositories/settings_repository.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';

void main() {
  testWidgets('provides concrete dependencies at application root', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final soundPlayer = _FakeGameSoundPlayer();
    late SettingsRepository settingsRepository;
    late GameRecordRepository gameRecordRepository;
    late GameSoundPlayer providedSoundPlayer;

    await tester.pumpWidget(
      AppProviderScope(
        preferences: preferences,
        gameSoundPlayer: soundPlayer,
        child: Consumer(
          builder: (context, ref, _) {
            settingsRepository = ref.read(settingsRepositoryProvider);
            gameRecordRepository = ref.read(gameRecordRepositoryProvider);
            providedSoundPlayer = ref.read(gameSoundPlayerProvider);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(settingsRepository, isA<SettingsRepositoryImpl>());
    expect(gameRecordRepository, isA<GameRecordRepositoryImpl>());
    expect(providedSoundPlayer, same(soundPlayer));
    expect(soundPlayer.prepareCalls, 1);
  });
}

final class _FakeGameSoundPlayer implements GameSoundPlayer {
  var prepareCalls = 0;

  @override
  Future<void> prepare() async => prepareCalls++;

  @override
  Future<void> play(GameSoundCue cue) async {}
}
