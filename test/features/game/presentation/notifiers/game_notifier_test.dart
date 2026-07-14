import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_notifier.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/domain/repositories/settings_repository.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';

void main() {
  test('waits 900 milliseconds before the CPU move by default', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(cpuTurnDelayProvider),
      const Duration(milliseconds: 900),
    );
  });

  test('ignores an out of bounds player move', () {
    final container = ProviderContainer(
      overrides: [cpuTurnDelayProvider.overrideWithValue(Duration.zero)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(gameProvider, (_, _) {});
    addTearDown(subscription.close);
    final notifier = container.read(gameProvider.notifier);
    final initialState = container.read(gameProvider);

    expect(() => notifier.play(9), returnsNormally);
    expect(container.read(gameProvider), initialState);
  });

  test('locks player moves while the CPU turn is pending', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(gameProvider.notifier);

    notifier.play(0);
    notifier.play(1);

    expect(container.read(gameProvider).isCpuThinking, isTrue);
    expect(container.read(gameProvider).game.board.cells[1], isNull);
  });

  test('restart invalidates a pending CPU turn', () async {
    final container = ProviderContainer(
      overrides: [cpuTurnDelayProvider.overrideWithValue(Duration.zero)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(gameProvider, (_, _) {});
    addTearDown(subscription.close);
    final notifier = container.read(gameProvider.notifier);

    notifier.play(0);
    notifier.restart();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(gameProvider).game, Game.initial());
    expect(container.read(gameProvider).isCpuThinking, isFalse);
  });

  test('persists a completed game once', () async {
    final repository = _RecordingGameRecordRepository();
    final container = ProviderContainer(
      overrides: [
        gameRecordRepositoryProvider.overrideWithValue(repository),
        cpuTurnDelayProvider.overrideWithValue(Duration.zero),
        settingsRepositoryProvider.overrideWithValue(
          _MemorySettingsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(gameProvider, (_, _) {});
    addTearDown(subscription.close);
    final recordsSubscription = container.listen(
      gameRecordsProvider,
      (_, _) {},
    );
    addTearDown(recordsSubscription.close);
    final notifier = container.read(gameProvider.notifier);
    expect(await container.read(gameRecordsProvider.future), isEmpty);

    await container
        .read(settingsProvider.notifier)
        .setDifficulty(GameDifficulty.medium);
    await _playTurn(notifier, 0);
    await _playTurn(notifier, 8);
    await _playTurn(notifier, 1);

    expect(repository.records, hasLength(1));
    expect(repository.records.single.outcome, GameOutcome.playerTwoWin);
    expect(repository.records.single.moveCount, 6);
    expect(
      await container.read(gameRecordsProvider.future),
      repository.records,
    );
    expect(repository.records.single.difficulty, GameDifficulty.medium);
    expect(repository.records.single.skin, GameSymbolSkin.classic);
  });

  test('exposes a completed game persistence failure', () async {
    final container = ProviderContainer(
      overrides: [
        gameRecordRepositoryProvider.overrideWithValue(
          _FailingGameRecordRepository(),
        ),
        cpuTurnDelayProvider.overrideWithValue(Duration.zero),
        settingsRepositoryProvider.overrideWithValue(
          _MemorySettingsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(gameProvider, (_, _) {});
    addTearDown(subscription.close);
    final notifier = container.read(gameProvider.notifier);

    await container
        .read(settingsProvider.notifier)
        .setDifficulty(GameDifficulty.medium);
    await _playTurn(notifier, 0);
    await _playTurn(notifier, 8);
    await _playTurn(notifier, 1);

    expect(container.read(gameProvider).historySaveFailed, isTrue);
  });

  test('ignores persistence failure after provider disposal', () async {
    final repository = _PendingFailingGameRecordRepository();
    final container = ProviderContainer(
      overrides: [
        gameRecordRepositoryProvider.overrideWithValue(repository),
        cpuTurnDelayProvider.overrideWithValue(Duration.zero),
        settingsRepositoryProvider.overrideWithValue(
          _MemorySettingsRepository(),
        ),
      ],
    );
    final subscription = container.listen(gameProvider, (_, _) {});
    final notifier = container.read(gameProvider.notifier);

    await container
        .read(settingsProvider.notifier)
        .setDifficulty(GameDifficulty.medium);
    await _playTurn(notifier, 0);
    await _playTurn(notifier, 8);
    await _playTurn(notifier, 1);
    await repository.saveStarted.future;

    subscription.close();
    container.dispose();
    repository.failSave();
    await Future<void>.delayed(Duration.zero);
  });

  test('ignores persistence failure from a previous game', () async {
    final repository = _PendingFailingGameRecordRepository();
    final container = ProviderContainer(
      overrides: [
        gameRecordRepositoryProvider.overrideWithValue(repository),
        cpuTurnDelayProvider.overrideWithValue(Duration.zero),
        settingsRepositoryProvider.overrideWithValue(
          _MemorySettingsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(gameProvider, (_, _) {});
    addTearDown(subscription.close);
    final notifier = container.read(gameProvider.notifier);

    await container
        .read(settingsProvider.notifier)
        .setDifficulty(GameDifficulty.medium);
    await _playTurn(notifier, 0);
    await _playTurn(notifier, 8);
    await _playTurn(notifier, 1);
    await repository.saveStarted.future;

    notifier.restart();
    repository.failSave();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(gameProvider).game, Game.initial());
    expect(container.read(gameProvider).historySaveFailed, isFalse);
  });

  test('changing difficulty preserves active game', () async {
    final repository = _MemorySettingsRepository();
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(gameProvider, (_, _) {});
    addTearDown(subscription.close);
    final notifier = container.read(gameProvider.notifier);

    notifier.play(0);
    final activeGame = container.read(gameProvider).game;
    await container
        .read(settingsProvider.notifier)
        .setDifficulty(GameDifficulty.easy);

    expect(container.read(gameProvider).game, activeGame);
    expect(container.read(settingsProvider).difficulty, GameDifficulty.easy);
    expect(repository.value.difficulty, GameDifficulty.easy);
  });

  test('changing skin preserves active game', () async {
    final repository = _MemorySettingsRepository();
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(gameProvider, (_, _) {});
    addTearDown(subscription.close);
    final notifier = container.read(gameProvider.notifier);

    notifier.play(0);
    final activeGame = container.read(gameProvider).game;
    await container
        .read(settingsProvider.notifier)
        .setSkin(GameSymbolSkin.football);

    expect(container.read(gameProvider).game, activeGame);
    expect(container.read(settingsProvider).skin, GameSymbolSkin.football);
  });
}

Future<void> _playTurn(GameNotifier notifier, int index) async {
  notifier.play(index);
  await Future<void>.delayed(Duration.zero);
}

class _RecordingGameRecordRepository implements GameRecordRepository {
  final records = <GameRecord>[];

  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<GameRecord>> getAll() async => List.unmodifiable(records);

  @override
  Future<void> save(GameRecord record) async {
    records.add(record);
  }
}

final class _FailingGameRecordRepository implements GameRecordRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<GameRecord>> getAll() async => [];

  @override
  Future<void> save(GameRecord record) => Future.error(StateError('failed'));
}

final class _PendingFailingGameRecordRepository
    implements GameRecordRepository {
  final saveStarted = Completer<void>();
  final _save = Completer<void>();

  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<GameRecord>> getAll() async => [];

  @override
  Future<void> save(GameRecord record) {
    saveStarted.complete();
    return _save.future;
  }

  void failSave() => _save.completeError(StateError('failed'));
}

final class _MemorySettingsRepository implements SettingsRepository {
  AppSettings value = AppSettings.defaults;

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<void> save(AppSettings preferences) async {
    value = preferences;
  }
}
