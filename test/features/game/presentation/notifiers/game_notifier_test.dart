import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/game_round.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_notifier.dart';
import 'package:xo_arena/features/history/presentation/history_providers.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/game_record_repository.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';

void main() {
  test('ignores an out of bounds player move', () {
    final container = ProviderContainer(
      overrides: [cpuTurnDelayProvider.overrideWithValue(Duration.zero)],
    );
    addTearDown(container.dispose);
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
    expect(container.read(gameProvider).round.cells[1], isNull);
  });

  test('restart invalidates a pending CPU turn', () async {
    final container = ProviderContainer(
      overrides: [cpuTurnDelayProvider.overrideWithValue(Duration.zero)],
    );
    addTearDown(container.dispose);
    final notifier = container.read(gameProvider.notifier);

    notifier.play(0);
    notifier.restart();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(gameProvider).round, GameRound.initial());
    expect(container.read(gameProvider).isCpuThinking, isFalse);
  });

  test('persists a completed round once', () async {
    final repository = _RecordingGameRecordRepository();
    final container = ProviderContainer(
      overrides: [
        gameRecordRepositoryProvider.overrideWithValue(repository),
        cpuTurnDelayProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(gameProvider.notifier);
    expect(await container.read(gameHistoryProvider.future), isEmpty);

    notifier.setDifficulty(GameDifficulty.medium);
    await _playTurn(notifier, 0);
    await _playTurn(notifier, 8);
    await _playTurn(notifier, 1);

    expect(repository.records, hasLength(1));
    expect(repository.records.single.outcome, GameOutcome.playerTwoWin);
    expect(repository.records.single.moveCount, 6);
    expect(
      await container.read(gameHistoryProvider.future),
      repository.records,
    );
  });

  test('exposes a completed round persistence failure', () async {
    final container = ProviderContainer(
      overrides: [
        gameRecordRepositoryProvider.overrideWithValue(
          _FailingGameRecordRepository(),
        ),
        cpuTurnDelayProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(gameProvider.notifier);

    notifier.setDifficulty(GameDifficulty.medium);
    await _playTurn(notifier, 0);
    await _playTurn(notifier, 8);
    await _playTurn(notifier, 1);

    expect(container.read(gameProvider).historySaveFailed, isTrue);
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
