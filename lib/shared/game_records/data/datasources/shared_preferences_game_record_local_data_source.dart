import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/game_record.dart';
import 'game_record_local_data_source.dart';

class SharedPreferencesGameRecordLocalDataSource
    implements GameRecordLocalDataSource {
  SharedPreferencesGameRecordLocalDataSource(this._preferences);

  static const _recordsKey = 'game_records';

  final SharedPreferences _preferences;
  Future<void> _mutationQueue = Future.value();

  @override
  Future<List<GameRecord>> getAll() async {
    final encodedRecords = _preferences.getString(_recordsKey);
    if (encodedRecords == null) {
      return [];
    }

    final records =
        (jsonDecode(encodedRecords) as List<dynamic>)
            .map((json) => GameRecord.fromJson(json as Map<String, dynamic>))
            .toList()
          ..sort(
            (first, second) => second.completedAt.compareTo(first.completedAt),
          );
    return records;
  }

  @override
  Future<void> save(GameRecord record) => _enqueueMutation(() async {
    final records = await getAll();
    records.removeWhere((existingRecord) => existingRecord.id == record.id);
    records.add(record);
    await _write(records);
  });

  @override
  Future<void> delete(String id) => _enqueueMutation(() async {
    final records = await getAll();
    records.removeWhere((record) => record.id == id);
    await _write(records);
  });

  @override
  Future<void> clear() =>
      _enqueueMutation(() => _preferences.remove(_recordsKey));

  Future<void> _enqueueMutation(Future<void> Function() mutation) {
    final result = _mutationQueue.then((_) => mutation());
    _mutationQueue = result.catchError((_) {});
    return result;
  }

  Future<void> _write(List<GameRecord> records) async {
    final encodedRecords = jsonEncode(
      records.map((record) => record.toJson()).toList(),
    );
    await _preferences.setString(_recordsKey, encodedRecords);
  }
}
