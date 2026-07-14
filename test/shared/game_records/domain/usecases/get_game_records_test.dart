import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';
import 'package:xo_arena/shared/game_records/domain/usecases/get_game_records.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

void main() {
  test('reads records through repository contract', () async {
    final record = GameRecord(
      id: 'game-1',
      playerOneName: 'You',
      playerTwoName: 'CPU',
      outcome: GameOutcome.draw,
      moveCount: 9,
      completedAt: DateTime.utc(2026, 7, 13),
      difficulty: GameDifficulty.hard,
      skin: GameSymbolSkin.classic,
    );
    final repository = _ReadOnlyRepository([record]);

    expect(await GetGameRecordsUseCase(repository)(), [record]);
  });
}

final class _ReadOnlyRepository implements GameRecordRepository {
  _ReadOnlyRepository(this.records);

  final List<GameRecord> records;

  @override
  Future<List<GameRecord>> getAll() async => records;

  @override
  Future<void> save(GameRecord record) => throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<void> clear() => throw UnimplementedError();
}
