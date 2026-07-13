import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xo_arena/features/history/usecases/clear_history.dart';
import 'package:xo_arena/features/history/usecases/delete_game_record.dart';
import 'package:xo_arena/features/history/usecases/get_history.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';

part 'history_providers.g.dart';

@Riverpod(keepAlive: true)
GetHistoryUseCase getHistoryUseCase(Ref ref) {
  return GetHistoryUseCase(ref.read(gameRecordRepositoryProvider));
}

@Riverpod(keepAlive: true)
DeleteGameRecordUseCase deleteGameRecordUseCase(Ref ref) {
  return DeleteGameRecordUseCase(ref.read(gameRecordRepositoryProvider));
}

@Riverpod(keepAlive: true)
ClearHistoryUseCase clearHistoryUseCase(Ref ref) {
  return ClearHistoryUseCase(ref.read(gameRecordRepositoryProvider));
}

@riverpod
Future<List<GameRecord>> gameHistory(Ref ref) {
  return ref.read(getHistoryUseCaseProvider)();
}
