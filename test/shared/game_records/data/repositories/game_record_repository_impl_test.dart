import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/shared/game_records/data/datasources/game_record_local_data_source.dart';
import 'package:xo_arena/shared/game_records/data/repositories/game_record_repository_impl.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';

void main() {
  late _RecordingGameRecordLocalDataSource dataSource;
  late GameRecordRepositoryImpl repository;

  setUp(() {
    dataSource = _RecordingGameRecordLocalDataSource();
    repository = GameRecordRepositoryImpl(dataSource);
  });

  test('gets records from the local data source', () async {
    final record = _record('game-1');
    dataSource.records = [record];

    expect(await repository.getAll(), [record]);
  });

  test('saves records through the local data source', () async {
    final record = _record('game-1');

    await repository.save(record);

    expect(dataSource.savedRecord, record);
  });

  test('deletes records through the local data source', () async {
    await repository.delete('game-1');

    expect(dataSource.deletedId, 'game-1');
  });

  test('clears records through the local data source', () async {
    await repository.clear();

    expect(dataSource.didClear, isTrue);
  });
}

class _RecordingGameRecordLocalDataSource implements GameRecordLocalDataSource {
  List<GameRecord> records = [];
  GameRecord? savedRecord;
  String? deletedId;
  bool didClear = false;

  @override
  Future<void> clear() async {
    didClear = true;
  }

  @override
  Future<void> delete(String id) async {
    deletedId = id;
  }

  @override
  Future<List<GameRecord>> getAll() async => records;

  @override
  Future<void> save(GameRecord record) async {
    savedRecord = record;
  }
}

GameRecord _record(String id) {
  return GameRecord(
    id: id,
    playerOneName: 'X',
    playerTwoName: 'O',
    winnerName: 'X',
    moveCount: 7,
    completedAt: DateTime.utc(2026, 7, 12),
  );
}
