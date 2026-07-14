import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/domain/repositories/settings_repository.dart';

part 'settings_providers.g.dart';

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  throw StateError('SettingsRepository must be provided by app composition.');
}

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  Future<void> _restoration = Future.value();
  Future<void> _persistenceQueue = Future.value();

  @override
  AppSettings build() {
    _restoration = _restore();
    unawaited(_restoration);
    return AppSettings.defaults;
  }

  Future<void> setTheme(AppThemePreference theme) async {
    await _update((settings) => settings.copyWith(theme: theme));
  }

  Future<void> setDifficulty(GameDifficulty difficulty) async {
    await _update((settings) => settings.copyWith(difficulty: difficulty));
  }

  Future<void> setSkin(GameSymbolSkin skin) async {
    await _update((settings) => settings.copyWith(skin: skin));
  }

  Future<void> setSoundEnabled(bool soundEnabled) async {
    await _update((settings) => settings.copyWith(soundEnabled: soundEnabled));
  }

  Future<void> _update(AppSettings Function(AppSettings) update) async {
    await _restoration;
    if (!ref.mounted) return;
    final next = update(state);
    if (next == state) return;
    state = next;
    await _enqueuePersistence(next);
  }

  Future<void> _restore() async {
    try {
      final stored = await ref.read(settingsRepositoryProvider).load();
      if (!ref.mounted) return;
      state = stored;
    } on Object {
      if (!ref.mounted) return;
      state = AppSettings.defaults;
    }
  }

  Future<void> _enqueuePersistence(AppSettings settings) {
    final result = _persistenceQueue.then((_) async {
      await ref.read(settingsRepositoryProvider).save(settings);
    });
    _persistenceQueue = result.catchError((_) {});
    return result;
  }
}
