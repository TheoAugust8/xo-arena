import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';

part 'game_record_providers.g.dart';

@Riverpod(keepAlive: true)
GameRecordRepository gameRecordRepository(Ref ref) {
  throw StateError('GameRecordRepository must be provided by app composition.');
}

@riverpod
Future<List<GameRecord>> gameRecords(Ref ref) {
  return ref.read(gameRecordRepositoryProvider).getAll();
}
