import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xo_arena/features/game/domain/entities/board.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_state.dart';

typedef StateLogSink = void Function(String message);

final class AppStateObserver extends ProviderObserver {
  const AppStateObserver() : _sink = null;

  @visibleForTesting
  const AppStateObserver.withSink(this._sink);

  final StateLogSink? _sink;

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    final name = _nameOf(context);
    if (value case final GameState state) {
      _log('[Riverpod] add $name:\n${_formatGameState(state)}');
      return;
    }

    _log('[Riverpod] add $name: ${_formatValue(value)}');
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    final name = _nameOf(context);
    if (previousValue case final GameState previous
        when newValue is GameState) {
      _log(
        '[Riverpod] update $name:\n${_formatGameStateChanges(previous, newValue)}',
      );
      return;
    }

    _log(
      '[Riverpod] update $name: '
      '${_formatValue(previousValue)} -> ${_formatValue(newValue)}',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    _log('[Riverpod] error ${_nameOf(context)}: $error\n$stackTrace');
  }

  void _log(String message) => (_sink ?? debugPrint)(message);

  String _nameOf(ProviderObserverContext context) {
    return context.provider.name ?? context.provider.runtimeType.toString();
  }

  String _formatValue(Object? value) => switch (value) {
    Duration() => '${value.inMilliseconds} ms',
    _ => value.toString(),
  };

  String _formatGameState(GameState state) {
    return [
      '  board: ${_formatBoard(state.game.board)}',
      '  currentPlayer: ${state.game.currentPlayer.name}',
      '  status: ${_formatStatus(state.game)}',
      '  isCpuThinking: ${state.isCpuThinking}',
      '  score: human ${state.playerScore}, cpu ${state.cpuScore}',
      '  historySaveFailed: ${state.historySaveFailed}',
    ].join('\n');
  }

  String _formatGameStateChanges(GameState previous, GameState next) {
    final changes = <String>[];
    final previousGame = previous.game;
    final nextGame = next.game;

    if (previousGame.board != nextGame.board) {
      changes.add(
        '  board: ${_formatBoard(previousGame.board)} -> '
        '${_formatBoard(nextGame.board)}',
      );
    }
    if (previousGame.currentPlayer != nextGame.currentPlayer) {
      changes.add(
        '  currentPlayer: ${previousGame.currentPlayer.name} -> '
        '${nextGame.currentPlayer.name}',
      );
    }
    if (previousGame.status != nextGame.status ||
        previousGame.winner != nextGame.winner) {
      changes.add(
        '  status: ${_formatStatus(previousGame)} -> ${_formatStatus(nextGame)}',
      );
    }
    if (previousGame.playerMarks[GamePlayer.human] !=
            nextGame.playerMarks[GamePlayer.human] ||
        previousGame.playerMarks[GamePlayer.cpu] !=
            nextGame.playerMarks[GamePlayer.cpu]) {
      changes.add(
        '  playerMarks: ${_formatPlayerMarks(previousGame)} -> '
        '${_formatPlayerMarks(nextGame)}',
      );
    }
    if (previous.isCpuThinking != next.isCpuThinking) {
      changes.add(
        '  isCpuThinking: ${previous.isCpuThinking} -> ${next.isCpuThinking}',
      );
    }
    if (previous.playerScore != next.playerScore ||
        previous.cpuScore != next.cpuScore) {
      changes.add(
        '  score: human ${previous.playerScore}, cpu ${previous.cpuScore} -> '
        'human ${next.playerScore}, cpu ${next.cpuScore}',
      );
    }
    if (previous.historySaveFailed != next.historySaveFailed) {
      changes.add(
        '  historySaveFailed: ${previous.historySaveFailed} -> '
        '${next.historySaveFailed}',
      );
    }

    return changes.isEmpty ? '  no visible change' : changes.join('\n');
  }

  String _formatBoard(Board board) {
    final cells = board.cells.map(_formatMark).toList(growable: false);
    return [
      cells.sublist(0, 3).join(),
      cells.sublist(3, 6).join(),
      cells.sublist(6, 9).join(),
    ].join('/');
  }

  String _formatStatus(Game game) => switch (game.status) {
    GameStatus.active => 'active',
    GameStatus.draw => 'draw',
    GameStatus.won => 'won by ${game.winner!.name}',
  };

  String _formatPlayerMarks(Game game) {
    return 'human ${_formatMark(game.markFor(GamePlayer.human))}, '
        'cpu ${_formatMark(game.markFor(GamePlayer.cpu))}';
  }

  String _formatMark(GameMark? mark) => switch (mark) {
    GameMark.x => 'X',
    GameMark.o => 'O',
    null => '.',
  };
}
