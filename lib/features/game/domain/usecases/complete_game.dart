import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record_participants.dart';
import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

final class CompleteGameUseCase {
  CompleteGameUseCase(this._repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final GameRecordRepository _repository;
  final DateTime Function() _now;

  Future<void> call({
    required Game game,
    required GameDifficulty difficulty,
    required GameSymbolSkin skin,
  }) {
    final outcome = switch ((game.status, game.winner)) {
      (GameStatus.won, GamePlayer.human) => GameOutcome.playerOneWin,
      (GameStatus.won, GamePlayer.cpu) => GameOutcome.playerTwoWin,
      (GameStatus.draw, _) => GameOutcome.draw,
      _ => throw StateError('Only completed games can persist.'),
    };
    final completedAt = _now();
    return _repository.save(
      GameRecord(
        id: completedAt.microsecondsSinceEpoch.toString(),
        playerOneName: GameRecordParticipants.human,
        playerTwoName: GameRecordParticipants.cpu,
        outcome: outcome,
        moveCount: game.board.moveCount,
        completedAt: completedAt,
        difficulty: difficulty,
        skin: skin,
      ),
    );
  }
}
