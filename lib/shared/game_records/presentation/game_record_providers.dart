import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xo_arena/shared/game_records/data/datasources/shared_preferences_game_record_local_data_source.dart';
import 'package:xo_arena/shared/game_records/data/repositories/game_record_repository_impl.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/game_record_repository.dart';

part 'game_record_providers.g.dart';

@Riverpod(keepAlive: true)
GameRecordRepository gameRecordRepository(Ref ref) {
  return _DeferredGameRecordRepository();
}

class _DeferredGameRecordRepository implements GameRecordRepository {
  late final Future<GameRecordRepositoryImpl> _repository = _createRepository();

  Future<GameRecordRepositoryImpl> _createRepository() async {
    final preferences = await SharedPreferences.getInstance();
    return GameRecordRepositoryImpl(
      SharedPreferencesGameRecordLocalDataSource(preferences),
    );
  }

  @override
  Future<void> clear() async {
    await (await _repository).clear();
  }

  @override
  Future<void> delete(String id) async {
    await (await _repository).delete(id);
  }

  @override
  Future<List<GameRecord>> getAll() async {
    return (await _repository).getAll();
  }

  @override
  Future<void> save(GameRecord record) async {
    await (await _repository).save(record);
  }
}
