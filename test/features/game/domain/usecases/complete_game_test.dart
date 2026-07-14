import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/entities/game_round.dart';
import 'package:xo_arena/features/game/domain/usecases/complete_game.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

void main() {
  test('builds and saves a completed game record', () async {
    final repository = _RecordingGameRecordRepository();
    final completedAt = DateTime.utc(2026, 7, 12);
    final useCase = CompleteGameUseCase(repository, now: () => completedAt);
    final round = GameRound(
      cells: [
        GameMark.player,
        GameMark.player,
        GameMark.player,
        GameMark.cpu,
        GameMark.cpu,
        null,
        null,
        null,
        null,
      ],
      status: GameStatus.playerWon,
      winningIndexes: [0, 1, 2],
    );

    await useCase(
      round: round,
      difficulty: GameDifficulty.medium,
      skin: GameSymbolSkin.football,
    );

    expect(
      repository.savedRecord,
      GameRecord(
        id: completedAt.microsecondsSinceEpoch.toString(),
        playerOneName: 'You',
        playerTwoName: 'CPU',
        outcome: GameOutcome.playerOneWin,
        moveCount: 5,
        completedAt: completedAt,
        difficulty: GameDifficulty.medium,
        skin: GameSymbolSkin.football,
      ),
    );
  });

  test('rejects active rounds', () {
    final useCase = CompleteGameUseCase(_RecordingGameRecordRepository());

    expect(
      () => useCase(
        round: GameRound.initial(),
        difficulty: GameDifficulty.hard,
        skin: GameSymbolSkin.classic,
      ),
      throwsStateError,
    );
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
