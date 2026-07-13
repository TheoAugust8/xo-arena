import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/usecases/complete_game.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/game_record_repository.dart';

void main() {
  test('saves a completed Game record', () async {
    final repository = _RecordingGameRecordRepository();
    final useCase = CompleteGameUseCase(repository);
    final record = GameRecord(
      id: 'game-1',
      playerOneName: 'X',
      playerTwoName: 'O',
      outcome: GameOutcome.playerOneWin,
      moveCount: 7,
      completedAt: DateTime.utc(2026, 7, 12),
    );

    await useCase(record);

    expect(repository.savedRecord, record);
  });
}

class _RecordingGameRecordRepository implements GameRecordRepository {
  GameRecord? savedRecord;

  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<GameRecord>> getAll() async => [];

  @override
  Future<void> save(GameRecord record) async {
    savedRecord = record;
  }
}
