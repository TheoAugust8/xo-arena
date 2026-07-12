import 'package:xo_arena/shared/game_records/domain/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/game_record_repository.dart';

final class CompleteGameUseCase {
  const CompleteGameUseCase(this._repository);

  final GameRecordRepository _repository;

  Future<void> call(GameRecord record) => _repository.save(record);
}
