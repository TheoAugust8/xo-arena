import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xo_arena/core/constants/app_storage_keys.dart';
import 'package:xo_arena/shared/game_records/data/datasources/game_record_local_data_source.dart';
import 'package:xo_arena/shared/game_records/data/models/game_record_dto.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';

class SharedPreferencesGameRecordLocalDataSource
    implements GameRecordLocalDataSource {
  SharedPreferencesGameRecordLocalDataSource(this._preferences);

  final SharedPreferences _preferences;
  // SharedPreferences has no transaction API. Serializing mutations prevents
  // overlapping read, modify, write cycles from losing records.
  Future<void> _mutationQueue = Future.value();

  @override
  Future<List<GameRecord>> getAll() => _mutationQueue.then((_) => _readAll());

  Future<List<GameRecord>> _readAll() async {
    final encodedRecords = _preferences.getString(AppStorageKeys.gameRecords);
    if (encodedRecords == null) {
      return [];
    }

    final List<dynamic> decodedRecords;
    try {
      decodedRecords = jsonDecode(encodedRecords) as List<dynamic>;
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }

    final records = <GameRecord>[];
    for (final encodedRecord in decodedRecords) {
      try {
        records.add(
          GameRecordDto.fromJson(
            encodedRecord as Map<String, dynamic>,
          ).toDomain(),
        );
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      } on ArgumentError {
        continue;
      }
    }
    records.sort(
      (first, second) => second.completedAt.compareTo(first.completedAt),
    );
    return records;
  }

  @override
  Future<void> save(GameRecord record) => _enqueueMutation(() async {
    final records = await _readAll();
    records.removeWhere((existingRecord) => existingRecord.id == record.id);
    records.add(record);
    await _write(records);
  });

  @override
  Future<void> delete(String id) => _enqueueMutation(() async {
    final records = await _readAll();
    records.removeWhere((record) => record.id == id);
    await _write(records);
  });

  @override
  Future<void> clear() => _enqueueMutation(() async {
    if (!_preferences.containsKey(AppStorageKeys.gameRecords)) return;
    final removed = await _preferences.remove(AppStorageKeys.gameRecords);
    if (!removed) {
      throw StateError('Unable to clear game records.');
    }
  });

  Future<void> _enqueueMutation(Future<void> Function() mutation) {
    final result = _mutationQueue.then((_) => mutation());
    _mutationQueue = result.catchError((_) {});
    return result;
  }

  Future<void> _write(List<GameRecord> records) async {
    final encodedRecords = jsonEncode(
      records
          .map((record) => GameRecordDto.fromDomain(record).toJson())
          .toList(),
    );
    final saved = await _preferences.setString(
      AppStorageKeys.gameRecords,
      encodedRecords,
    );
    if (!saved) {
      throw StateError('Unable to persist game records.');
    }
  }
}
