import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/history/presentation/history_providers.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

void main() {
  test('wires History use cases to overridden repository contract', () async {
    final repository = _MemoryGameRecordRepository([
      _record('first'),
      _record('second'),
    ]);
    final container = ProviderContainer(
      overrides: [gameRecordRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(deleteGameRecordUseCaseProvider)('first');
    expect(await repository.getAll(), hasLength(1));

    await container.read(clearHistoryUseCaseProvider)();
    expect(await repository.getAll(), isEmpty);
  });
}

final class _MemoryGameRecordRepository implements GameRecordRepository {
  _MemoryGameRecordRepository(Iterable<GameRecord> records)
    : _records = [...records];

  final List<GameRecord> _records;

  @override
  Future<void> clear() async => _records.clear();

  @override
  Future<void> delete(String id) async {
    _records.removeWhere((record) => record.id == id);
  }

  @override
  Future<List<GameRecord>> getAll() async => List.unmodifiable(_records);

  @override
  Future<void> save(GameRecord record) async => _records.add(record);
}

GameRecord _record(String id) {
  return GameRecord(
    id: id,
    playerOneName: 'X',
    playerTwoName: 'O',
    outcome: GameOutcome.playerOneWin,
    moveCount: 7,
    completedAt: DateTime.utc(2026, 7, 12),
    difficulty: GameDifficulty.hard,
    skin: GameSymbolSkin.classic,
  );
}
