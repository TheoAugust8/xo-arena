import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/domain/usecases/complete_game.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

void main() {
  test('builds and saves completed game record', () async {
    final repository = _RecordingGameRecordRepository();
    final completedAt = DateTime.utc(2026, 7, 12);
    final useCase = CompleteGameUseCase(repository, now: () => completedAt);
    final game = _completedHumanWin();

    await useCase(
      game: game,
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

  for (final scenario in [
    (_completedCpuWin, GameOutcome.playerTwoWin, 6),
    (_completedDraw, GameOutcome.draw, 9),
  ]) {
    test('persists ${scenario.$2.name} outcome', () async {
      final repository = _RecordingGameRecordRepository();
      final completedAt = DateTime.utc(2026, 7, 12);
      final useCase = CompleteGameUseCase(repository, now: () => completedAt);

      await useCase(
        game: scenario.$1(),
        difficulty: GameDifficulty.hard,
        skin: GameSymbolSkin.classic,
      );

      expect(repository.savedRecord?.outcome, scenario.$2);
      expect(repository.savedRecord?.moveCount, scenario.$3);
    });
  }

  test('rejects active games', () {
    final useCase = CompleteGameUseCase(_RecordingGameRecordRepository());

    expect(
      () => useCase(
        game: Game.initial(),
        difficulty: GameDifficulty.hard,
        skin: GameSymbolSkin.classic,
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'Only completed games can persist.',
        ),
      ),
    );
  });
}

Game _completedHumanWin() {
  var game = Game.initial();
  for (final move in const [
    (GamePlayer.human, 0),
    (GamePlayer.cpu, 3),
    (GamePlayer.human, 1),
    (GamePlayer.cpu, 4),
    (GamePlayer.human, 2),
  ]) {
    game = game.applyMove(by: move.$1, index: move.$2);
  }
  return game;
}

Game _completedCpuWin() => _gameAfter([0, 3, 1, 4, 8, 5]);

Game _completedDraw() => _gameAfter([0, 1, 2, 4, 3, 5, 7, 6, 8]);

Game _gameAfter(List<int> moves) {
  var game = Game.initial();
  for (final move in moves) {
    game = game.applyMove(by: game.currentPlayer, index: move);
  }
  return game;
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
