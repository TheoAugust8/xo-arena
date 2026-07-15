import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xo_arena/core/constants/app_storage_keys.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/data/datasources/shared_preferences_game_record_local_data_source.dart';
import 'package:xo_arena/shared/game_records/data/models/game_record_dto.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

void main() {
  late SharedPreferencesGameRecordLocalDataSource dataSource;
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    dataSource = SharedPreferencesGameRecordLocalDataSource(preferences);
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

  test('retains only the 100 newest game records', () async {
    final firstDate = DateTime.utc(2026);
    for (var index = 0; index <= 100; index++) {
      await dataSource.save(
        _record(
          id: 'game-$index',
          completedAt: firstDate.add(Duration(days: index)),
        ),
      );
    }

    final records = await dataSource.getAll();

    expect(records, hasLength(100));
    expect(records.first.id, 'game-100');
    expect(records.map((record) => record.id), isNot(contains('game-0')));
    final storedRecords =
        jsonDecode(preferences.getString(AppStorageKeys.gameRecords)!)
            as List<Object?>;
    expect(storedRecords, hasLength(100));
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
      ...GameRecordDto.fromDomain(validRecord).toJson(),
      'id': 'malformed',
      'skin': 'unknown',
    };
    SharedPreferences.setMockInitialValues({
      'game_records': jsonEncode([
        malformedRecord,
        GameRecordDto.fromDomain(validRecord).toJson(),
      ]),
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

  test('returns empty history when stored payload is not a list', () async {
    SharedPreferences.setMockInitialValues({'game_records': '{}'});
    final source = SharedPreferencesGameRecordLocalDataSource(
      await SharedPreferences.getInstance(),
    );

    expect(await source.getAll(), isEmpty);
  });

  test('skips record with invalid primitive type', () async {
    final validRecord = _record(id: 'valid');
    final invalidRecord = <String, dynamic>{
      ...GameRecordDto.fromDomain(validRecord).toJson(),
      'id': 'invalid',
      'moveCount': '7',
    };
    SharedPreferences.setMockInitialValues({
      'game_records': jsonEncode([
        invalidRecord,
        GameRecordDto.fromDomain(validRecord).toJson(),
      ]),
    });
    final source = SharedPreferencesGameRecordLocalDataSource(
      await SharedPreferences.getInstance(),
    );

    expect(await source.getAll(), [validRecord]);
  });

  test('skips record with fractional move count', () async {
    final validRecord = _record(id: 'valid');
    final invalidRecord = <String, dynamic>{
      ...GameRecordDto.fromDomain(validRecord).toJson(),
      'id': 'invalid',
      'moveCount': 7.5,
    };
    SharedPreferences.setMockInitialValues({
      'game_records': jsonEncode([
        invalidRecord,
        GameRecordDto.fromDomain(validRecord).toJson(),
      ]),
    });
    final source = SharedPreferencesGameRecordLocalDataSource(
      await SharedPreferences.getInstance(),
    );

    expect(await source.getAll(), [validRecord]);
  });

  test('throws when SharedPreferences returns false while saving', () async {
    final source = SharedPreferencesGameRecordLocalDataSource(
      _FailingWriteSharedPreferences(),
    );

    await expectLater(source.save(_record(id: 'game-1')), throwsStateError);
  });

  test('throws when SharedPreferences returns false while clearing', () async {
    final source = SharedPreferencesGameRecordLocalDataSource(
      _FailingClearSharedPreferences(),
    );

    await expectLater(source.clear(), throwsStateError);
  });

  test('continues mutation queue after failed save', () async {
    final preferences = _RecoveringSharedPreferences();
    final source = SharedPreferencesGameRecordLocalDataSource(preferences);

    await expectLater(source.save(_record(id: 'failed')), throwsStateError);
    await source.save(_record(id: 'saved'));

    expect(await source.getAll(), [_record(id: 'saved')]);
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

final class _FailingWriteSharedPreferences extends Fake
    implements SharedPreferences {
  @override
  String? getString(String key) => null;

  @override
  Future<bool> setString(String key, String value) async => false;
}

final class _FailingClearSharedPreferences extends Fake
    implements SharedPreferences {
  @override
  bool containsKey(String key) => true;

  @override
  Future<bool> remove(String key) async => false;
}

final class _RecoveringSharedPreferences extends Fake
    implements SharedPreferences {
  var _writeCount = 0;
  String? _encodedRecords;

  @override
  String? getString(String key) => _encodedRecords;

  @override
  Future<bool> setString(String key, String value) async {
    _writeCount++;
    if (_writeCount == 1) return false;
    _encodedRecords = value;
    return true;
  }
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
