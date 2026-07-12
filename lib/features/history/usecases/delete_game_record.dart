import 'package:xo_arena/shared/game_records/domain/game_record_repository.dart';

final class DeleteGameRecordUseCase {
  const DeleteGameRecordUseCase(this._repository);

  final GameRecordRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
