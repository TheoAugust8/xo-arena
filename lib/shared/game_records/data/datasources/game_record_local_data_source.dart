import '../../domain/game_record.dart';

abstract interface class GameRecordLocalDataSource {
  Future<List<GameRecord>> getAll();
  Future<void> save(GameRecord record);
  Future<void> delete(String id);
  Future<void> clear();
}
