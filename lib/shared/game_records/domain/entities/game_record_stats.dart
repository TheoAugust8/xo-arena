import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';

final class GameRecordStats {
  const GameRecordStats({
    required this.wins,
    required this.draws,
    required this.losses,
    required this.winRate,
  });

  static const empty = GameRecordStats(
    wins: 0,
    draws: 0,
    losses: 0,
    winRate: 0,
  );

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

  final int wins;
  final int draws;
  final int losses;
  final int winRate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameRecordStats &&
          wins == other.wins &&
          draws == other.draws &&
          losses == other.losses &&
          winRate == other.winRate;

  @override
  int get hashCode => Object.hash(wins, draws, losses, winRate);
}
