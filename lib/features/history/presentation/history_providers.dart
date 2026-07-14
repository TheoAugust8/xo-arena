import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xo_arena/features/history/domain/usecases/clear_history.dart';
import 'package:xo_arena/features/history/domain/usecases/delete_game_record.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';

part 'history_providers.g.dart';

@Riverpod(keepAlive: true)
DeleteGameRecordUseCase deleteGameRecordUseCase(Ref ref) {
  return DeleteGameRecordUseCase(ref.read(gameRecordRepositoryProvider));
}

@Riverpod(keepAlive: true)
ClearHistoryUseCase clearHistoryUseCase(Ref ref) {
  return ClearHistoryUseCase(ref.read(gameRecordRepositoryProvider));
}
