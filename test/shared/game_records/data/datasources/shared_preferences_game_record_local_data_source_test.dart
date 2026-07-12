import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xo_arena/shared/game_records/data/datasources/shared_preferences_game_record_local_data_source.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';

void main() {
  late SharedPreferencesGameRecordLocalDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dataSource = SharedPreferencesGameRecordLocalDataSource(
      await SharedPreferences.getInstance(),
    );
  });

  test('saves and reads a game record', () async {
    final record = _record(id: 'game-1');

    await dataSource.save(record);

    expect(await dataSource.getAll(), [record]);
  });

  test('returns records newest first', () async {
    final older = _record(id: 'older', completedAt: DateTime.utc(2026, 7, 11));
    final newer = _record(id: 'newer', completedAt: DateTime.utc(2026, 7, 12));

    await dataSource.save(older);
    await dataSource.save(newer);

    expect(await dataSource.getAll(), [newer, older]);
  });

  test('deletes the record with the requested id', () async {
    final retained = _record(id: 'retained');
    final deleted = _record(id: 'deleted');
    await dataSource.save(retained);
    await dataSource.save(deleted);

    await dataSource.delete(deleted.id);

    expect(await dataSource.getAll(), [retained]);
  });

  test('serializes concurrent deletes so neither record is restored', () async {
    final first = _record(id: 'first');
    final second = _record(id: 'second');
    await dataSource.save(first);
    await dataSource.save(second);

    await Future.wait([
      dataSource.delete(first.id),
      dataSource.delete(second.id),
    ]);

    expect(await dataSource.getAll(), isEmpty);
  });

  test('serializes a clear after a concurrent save', () async {
    await dataSource.save(_record(id: 'existing'));

    await Future.wait([
      dataSource.save(_record(id: 'new')),
      dataSource.clear(),
    ]);

    expect(await dataSource.getAll(), isEmpty);
  });

  test('clears all records', () async {
    await dataSource.save(_record(id: 'game-1'));
    await dataSource.save(_record(id: 'game-2'));

    await dataSource.clear();

    expect(await dataSource.getAll(), isEmpty);
  });
}

GameRecord _record({required String id, DateTime? completedAt}) {
  return GameRecord(
    id: id,
    playerOneName: 'X',
    playerTwoName: 'O',
    winnerName: 'X',
    moveCount: 7,
    completedAt: completedAt ?? DateTime.utc(2026, 7, 12),
  );
}
