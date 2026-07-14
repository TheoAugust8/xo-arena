import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/data/datasources/game_record_local_data_source.dart';

class SharedPreferencesGameRecordLocalDataSource
    implements GameRecordLocalDataSource {
  SharedPreferencesGameRecordLocalDataSource(this._preferences);

  static const _recordsKey = 'game_records';

  final SharedPreferences _preferences;
  Future<void> _mutationQueue = Future.value();

  @override
  Future<List<GameRecord>> getAll() => _mutationQueue.then((_) => _readAll());

  Future<List<GameRecord>> _readAll() async {
    final encodedRecords = _preferences.getString(_recordsKey);
    if (encodedRecords == null) {
      return [];
    }

    final List<dynamic> decodedRecords;
    try {
      decodedRecords = jsonDecode(encodedRecords) as List<dynamic>;
    } on Object {
      return [];
    }

    final records = <GameRecord>[];
    for (final encodedRecord in decodedRecords) {
      try {
        records.add(GameRecord.fromJson(encodedRecord as Map<String, dynamic>));
      } on Object {
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
    if (!_preferences.containsKey(_recordsKey)) return;
    final removed = await _preferences.remove(_recordsKey);
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
      records.map((record) => record.toJson()).toList(),
    );
    final saved = await _preferences.setString(_recordsKey, encodedRecords);
    if (!saved) {
      throw StateError('Unable to persist game records.');
    }
  }
}
