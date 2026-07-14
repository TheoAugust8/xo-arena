import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';

part 'game_record_stats.freezed.dart';

@freezed
abstract class GameRecordStats with _$GameRecordStats {
  const GameRecordStats._();

  const factory GameRecordStats({
    required int wins,
    required int draws,
    required int losses,
    required int winRate,
  }) = _GameRecordStats;

  factory GameRecordStats.fromRecords(Iterable<GameRecord> records) {
    var wins = 0;
    var draws = 0;
    var losses = 0;
    for (final record in records) {
      switch (record.outcome) {
        case GameOutcome.playerOneWin:
          wins++;
        case GameOutcome.playerTwoWin:
          losses++;
        case GameOutcome.draw:
          draws++;
      }
    }
    final total = wins + draws + losses;
    return GameRecordStats(
      wins: wins,
      draws: draws,
      losses: losses,
      winRate: total == 0 ? 0 : (wins / total * 100).round(),
    );
  }
}
