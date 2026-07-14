import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/domain/repositories/settings_repository.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';

void main() {
  test('exposes defaults before asynchronous restoration', () {
    final repository = _MemorySettingsRepository(
      const AppSettings(
        difficulty: GameDifficulty.easy,
        skin: GameSymbolSkin.football,
      ),
    );
    final container = _container(repository);
    addTearDown(container.dispose);

    expect(container.read(settingsProvider), AppSettings.defaults);
  });

  test('restores persisted settings', () async {
    const stored = AppSettings(
      theme: AppThemePreference.light,
      difficulty: GameDifficulty.easy,
      skin: GameSymbolSkin.football,
    );
    final container = _container(_MemorySettingsRepository(stored));
    addTearDown(container.dispose);

    container.read(settingsProvider);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(settingsProvider), stored);
  });

  test('serializes settings writes in selection order', () async {
    final repository = _OrderedSettingsRepository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final notifier = container.read(settingsProvider.notifier);

    final firstWrite = notifier.setDifficulty(GameDifficulty.easy);
    await repository.firstWriteStarted.future;
    final secondWrite = notifier.setSkin(GameSymbolSkin.tennis);
    repository.releaseFirstWrite();
    await Future.wait([firstWrite, secondWrite]);

    expect(repository.saved, [
      const AppSettings(
        difficulty: GameDifficulty.easy,
        skin: GameSymbolSkin.classic,
      ),
      const AppSettings(
        difficulty: GameDifficulty.easy,
        skin: GameSymbolSkin.tennis,
      ),
    ]);
  });

  test('persists theme and sound selections', () async {
    final repository = _MemorySettingsRepository(AppSettings.defaults);
    final container = _container(repository);
    addTearDown(container.dispose);
    final notifier = container.read(settingsProvider.notifier);

    await notifier.setTheme(AppThemePreference.dark);
    await notifier.setSoundEnabled(false);

    expect(container.read(settingsProvider).theme, AppThemePreference.dark);
    expect(container.read(settingsProvider).soundEnabled, isFalse);
    expect(repository.value, container.read(settingsProvider));
  });

  test('skips persistence when settings stay unchanged', () async {
    final repository = _RecordingSettingsRepository();
    final container = _container(repository);
    addTearDown(container.dispose);

    await container
        .read(settingsProvider.notifier)
        .setDifficulty(AppSettings.defaults.difficulty);

    expect(repository.saved, isEmpty);
  });

  test(
    'preserves restored fields when selection happens during load',
    () async {
      const stored = AppSettings(
        theme: AppThemePreference.light,
        difficulty: GameDifficulty.easy,
        skin: GameSymbolSkin.football,
      );
      final repository = _PendingLoadSettingsRepository();
      final container = _container(repository);
      addTearDown(container.dispose);
      final notifier = container.read(settingsProvider.notifier);

      final persistence = notifier.setSoundEnabled(false);
      repository.completeLoad(stored);
      await persistence;

      final expected = stored.copyWith(soundEnabled: false);
      expect(container.read(settingsProvider), expected);
      expect(repository.saved, [expected]);
    },
  );

  test('keeps defaults writable when restoration fails', () async {
    final repository = _FailingLoadSettingsRepository();
    final container = _container(repository);
    addTearDown(container.dispose);
    final notifier = container.read(settingsProvider.notifier);

    await notifier.setDifficulty(GameDifficulty.easy);

    expect(
      container.read(settingsProvider),
      AppSettings.defaults.copyWith(difficulty: GameDifficulty.easy),
    );
    expect(repository.saved, [container.read(settingsProvider)]);
  });
}

ProviderContainer _container(SettingsRepository repository) {
  return ProviderContainer(
    overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
  );
}

class _MemorySettingsRepository implements SettingsRepository {
  _MemorySettingsRepository(this.value);

  AppSettings value;

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<void> save(AppSettings settings) async {
    value = settings;
  }
}

final class _OrderedSettingsRepository extends _MemorySettingsRepository {
  _OrderedSettingsRepository() : super(AppSettings.defaults);

  final firstWriteStarted = Completer<void>();
  final _release = Completer<void>();
  final saved = <AppSettings>[];
  var _writeCount = 0;

  @override
  Future<void> save(AppSettings settings) async {
    _writeCount++;
    if (_writeCount == 1) {
      firstWriteStarted.complete();
      await _release.future;
    }
    saved.add(settings);
    await super.save(settings);
  }

  void releaseFirstWrite() => _release.complete();
}

final class _RecordingSettingsRepository extends _MemorySettingsRepository {
  _RecordingSettingsRepository() : super(AppSettings.defaults);

  final saved = <AppSettings>[];

  @override
  Future<void> save(AppSettings settings) async {
    saved.add(settings);
    await super.save(settings);
  }
}

final class _PendingLoadSettingsRepository implements SettingsRepository {
  final _load = Completer<AppSettings>();
  final saved = <AppSettings>[];

  @override
  Future<AppSettings> load() => _load.future;

  @override
  Future<void> save(AppSettings settings) async {
    saved.add(settings);
  }

  void completeLoad(AppSettings settings) => _load.complete(settings);
}

final class _FailingLoadSettingsRepository implements SettingsRepository {
  final saved = <AppSettings>[];

  @override
  Future<AppSettings> load() => Future.error(StateError('failed'));

  @override
  Future<void> save(AppSettings settings) async {
    saved.add(settings);
  }
}
