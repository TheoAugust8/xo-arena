import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';

final class GetGameRecordsUseCase {
  const GetGameRecordsUseCase(this._repository);

  final GameRecordRepository _repository;

  Future<List<GameRecord>> call() => _repository.getAll();
}
