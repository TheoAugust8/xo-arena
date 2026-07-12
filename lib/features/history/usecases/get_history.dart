import 'package:xo_arena/shared/game_records/domain/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/game_record_repository.dart';

final class GetHistoryUseCase {
  const GetHistoryUseCase(this._repository);

  final GameRecordRepository _repository;

  Future<List<GameRecord>> call() => _repository.getAll();
}
