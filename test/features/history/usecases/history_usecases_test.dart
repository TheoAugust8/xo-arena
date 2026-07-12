import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/history/usecases/clear_history.dart';
import 'package:xo_arena/features/history/usecases/delete_game_record.dart';
import 'package:xo_arena/features/history/usecases/get_history.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/game_record_repository.dart';

void main() {
  late InMemoryGameRecordRepository repository;
  late GetHistoryUseCase getHistory;
  late DeleteGameRecordUseCase deleteGameRecord;
  late ClearHistoryUseCase clearHistory;

  setUp(() {
    repository = InMemoryGameRecordRepository();
    getHistory = GetHistoryUseCase(repository);
    deleteGameRecord = DeleteGameRecordUseCase(repository);
    clearHistory = ClearHistoryUseCase(repository);
  });

  test('gets saved game records', () async {
    final record = _record(id: 'game-1');
    await repository.save(record);

    expect(await getHistory(), [record]);
  });

  test('deletes a game record by id', () async {
    final record = _record(id: 'game-1');
    await repository.save(record);

    await deleteGameRecord('game-1');

    expect(await getHistory(), isEmpty);
  });

  test('clears all game records', () async {
    await repository.save(_record(id: 'game-1'));
    await repository.save(_record(id: 'game-2'));

    await clearHistory();

    expect(await getHistory(), isEmpty);
  });
}

class InMemoryGameRecordRepository implements GameRecordRepository {
  final List<GameRecord> _records = [];

  @override
  Future<void> clear() async {
    _records.clear();
  }

  @override
  Future<void> delete(String id) async {
    _records.removeWhere((record) => record.id == id);
  }

  @override
  Future<List<GameRecord>> getAll() async => List.of(_records);

  @override
  Future<void> save(GameRecord record) async {
    _records.removeWhere((existingRecord) => existingRecord.id == record.id);
    _records.add(record);
  }
}

GameRecord _record({required String id}) {
  return GameRecord(
    id: id,
    playerOneName: 'X',
    playerTwoName: 'O',
    winnerName: 'X',
    moveCount: 7,
    completedAt: DateTime.utc(2026, 7, 12),
  );
}
