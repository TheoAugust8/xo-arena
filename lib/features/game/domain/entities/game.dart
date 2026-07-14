import 'package:xo_arena/features/game/domain/entities/board.dart';
import 'package:xo_arena/features/game/domain/entities/game_move_exception.dart';
import 'package:xo_arena/features/game/domain/services/game_rules.dart';

enum GamePlayer { human, cpu }

enum GameStatus { active, won, draw }

final class Game {
  Game._({
    required this.board,
    required this.currentPlayer,
    required Map<GamePlayer, GameMark> playerMarks,
  }) : playerMarks = Map.unmodifiable(playerMarks);

  factory Game.initial({
    Map<GamePlayer, GameMark> playerMarks = const {
      GamePlayer.human: GameMark.x,
      GamePlayer.cpu: GameMark.o,
    },
  }) {
    if (playerMarks.length != GamePlayer.values.length ||
        !playerMarks.keys.toSet().containsAll(GamePlayer.values) ||
        playerMarks.values.toSet().length != GameMark.values.length) {
      throw ArgumentError.value(
        playerMarks,
        'playerMarks',
        'must map every player to a distinct mark',
      );
    }
    return Game._(
      board: Board.empty(),
      currentPlayer: GamePlayer.human,
      playerMarks: playerMarks,
    );
  }

  final Board board;
  final GamePlayer currentPlayer;
  final Map<GamePlayer, GameMark> playerMarks;

  GameEvaluation get _evaluation => GameRules.evaluate(board);

  GameStatus get status {
    final evaluation = _evaluation;
    if (evaluation.winningMark != null) return GameStatus.won;
    if (evaluation.isDraw) return GameStatus.draw;
    return GameStatus.active;
  }

  bool get isComplete => status != GameStatus.active;

  List<int> get winningIndexes => _evaluation.winningIndexes;

  GamePlayer? get winner {
    final mark = _evaluation.winningMark;
    return mark == null ? null : playerFor(mark);
  }

  GameMark markFor(GamePlayer player) => playerMarks[player]!;

  GamePlayer playerFor(GameMark mark) {
    return playerMarks.entries.singleWhere((entry) => entry.value == mark).key;
  }

  GamePlayer? playerAt(int index) {
    final mark = board.cells[index];
    return mark == null ? null : playerFor(mark);
  }

  Game applyMove({required GamePlayer by, required int index}) {
    if (isComplete) {
      throw const GameMoveException(GameMoveFailure.gameComplete);
    }
    if (currentPlayer != by) {
      throw const GameMoveException(GameMoveFailure.wrongPlayer);
    }

    final nextBoard = board.placeMark(index, markFor(by));
    final nextEvaluation = GameRules.evaluate(nextBoard);
    return Game._(
      board: nextBoard,
      currentPlayer:
          nextEvaluation.winningMark == null && !nextEvaluation.isDraw
          ? _otherPlayer(by)
          : by,
      playerMarks: playerMarks,
    );
  }

  GamePlayer _otherPlayer(GamePlayer player) => switch (player) {
    GamePlayer.human => GamePlayer.cpu,
    GamePlayer.cpu => GamePlayer.human,
  };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Game &&
            board == other.board &&
            currentPlayer == other.currentPlayer &&
            GamePlayer.values.every(
              (player) => playerMarks[player] == other.playerMarks[player],
            );
  }

  @override
  int get hashCode => Object.hash(
    board,
    currentPlayer,
    playerMarks[GamePlayer.human],
    playerMarks[GamePlayer.cpu],
  );

  @override
  String toString() {
    return 'Game(board: $board, currentPlayer: $currentPlayer, '
        'playerMarks: $playerMarks)';
  }
}
