import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';
import 'package:xo_arena/shared/game_records/data/datasources/game_record_local_data_source.dart';

class GameRecordRepositoryImpl implements GameRecordRepository {
  GameRecordRepositoryImpl(this._localDataSource);

  final GameRecordLocalDataSource _localDataSource;

  @override
  Future<void> clear() => _localDataSource.clear();

  @override
  Future<void> delete(String id) => _localDataSource.delete(id);

  @override
  Future<List<GameRecord>> getAll() => _localDataSource.getAll();

  @override
  Future<void> save(GameRecord record) => _localDataSource.save(record);
}
