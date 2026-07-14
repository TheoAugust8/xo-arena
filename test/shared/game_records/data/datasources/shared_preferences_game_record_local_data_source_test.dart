import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/data/datasources/shared_preferences_game_record_local_data_source.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

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

  test('waits for a pending save before reading records', () async {
    final preferences = _DelayedSharedPreferences();
    final source = SharedPreferencesGameRecordLocalDataSource(preferences);
    final record = _record(id: 'pending');

    final save = source.save(record);
    await preferences.writeStarted.future;
    final read = source.getAll();

    preferences.completeWrite();

    await save;
    expect(await read, [record]);
  });

  test('clears all records', () async {
    await dataSource.save(_record(id: 'game-1'));
    await dataSource.save(_record(id: 'game-2'));

    await dataSource.clear();

    expect(await dataSource.getAll(), isEmpty);
  });

  test('skips malformed records while preserving valid records', () async {
    final validRecord = _record(id: 'valid');
    final malformedRecord = <String, dynamic>{
      ...validRecord.toJson(),
      'id': 'malformed',
      'skin': 'unknown',
    };
    SharedPreferences.setMockInitialValues({
      'game_records': jsonEncode([malformedRecord, validRecord.toJson()]),
    });
    final source = SharedPreferencesGameRecordLocalDataSource(
      await SharedPreferences.getInstance(),
    );

    expect(await source.getAll(), [validRecord]);
  });

  test('returns empty history when stored payload is corrupt', () async {
    SharedPreferences.setMockInitialValues({'game_records': '{not-json'});
    final source = SharedPreferencesGameRecordLocalDataSource(
      await SharedPreferences.getInstance(),
    );

    expect(await source.getAll(), isEmpty);
  });
}

final class _DelayedSharedPreferences extends Fake
    implements SharedPreferences {
  final writeStarted = Completer<void>();
  final _writeGate = Completer<void>();
  String? _encodedRecords;

  @override
  String? getString(String key) => _encodedRecords;

  @override
  Future<bool> setString(String key, String value) async {
    if (!writeStarted.isCompleted) writeStarted.complete();
    await _writeGate.future;
    _encodedRecords = value;
    return true;
  }

  void completeWrite() => _writeGate.complete();
}

GameRecord _record({required String id, DateTime? completedAt}) {
  return GameRecord(
    id: id,
    playerOneName: 'X',
    playerTwoName: 'O',
    outcome: GameOutcome.playerOneWin,
    moveCount: 7,
    completedAt: completedAt ?? DateTime.utc(2026, 7, 12),
    difficulty: GameDifficulty.hard,
    skin: GameSymbolSkin.classic,
  );
}
