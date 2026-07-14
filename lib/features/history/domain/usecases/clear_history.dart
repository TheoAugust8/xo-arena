import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';

final class ClearHistoryUseCase {
  const ClearHistoryUseCase(this._repository);

  final GameRecordRepository _repository;

  Future<void> call() => _repository.clear();
}
