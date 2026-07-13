import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:xo_arena/features/game/domain/cpu_strategy.dart';
import 'package:xo_arena/features/game/domain/game_rules.dart';
import 'package:xo_arena/features/game/domain/game_round.dart';
import 'package:xo_arena/features/game/presentation/models/game_symbol_skin.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_state.dart';
import 'package:xo_arena/features/game/usecases/complete_game.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';

part 'game_notifier.g.dart';

@riverpod
Duration cpuTurnDelay(Ref ref) => const Duration(milliseconds: 400);

@Riverpod(keepAlive: true)
CompleteGameUseCase completeGameUseCase(Ref ref) {
  return CompleteGameUseCase(ref.read(gameRecordRepositoryProvider));
}

@Riverpod(keepAlive: true)
class GameNotifier extends _$GameNotifier {
  var _generation = 0;
  Timer? _cpuTimer;

  @override
  GameState build() {
    ref.onDispose(() {
      _generation++;
      _cpuTimer?.cancel();
    });
    return GameState.initial();
  }

  void play(int index) {
    if (state.isCpuThinking) {
      return;
    }
    final GameRound next;
    try {
      next = GameRules.applyMove(state.round, index, GameMark.player);
    } on GameMoveException {
      return;
    }
    state = state.copyWith(
      round: next,
      playerScore: next.status == GameStatus.playerWon
          ? state.playerScore + 1
          : state.playerScore,
    );
    if (next.isComplete) {
      _saveCompletedRound(next);
    } else {
      _scheduleCpu();
    }
  }

  void restart() {
    _generation++;
    _cpuTimer?.cancel();
    state = state.copyWith(
      round: GameRound.initial(),
      isCpuThinking: false,
      historySaveFailed: false,
    );
  }

  void setDifficulty(GameDifficulty value) {
    state = state.copyWith(difficulty: value);
    restart();
  }

  void setSkin(GameSymbolSkin value) => state = state.copyWith(skin: value);
  void _scheduleCpu() {
    final generation = ++_generation;
    state = state.copyWith(isCpuThinking: true);
    _cpuTimer?.cancel();
    _cpuTimer = Timer(ref.read(cpuTurnDelayProvider), () {
      if (generation != _generation || state.round.isComplete) return;
      final move = CpuStrategyFactory.forDifficulty(
        state.difficulty,
      ).chooseMove(state.round.cells);
      final next = GameRules.applyMove(state.round, move, GameMark.cpu);
      state = state.copyWith(
        round: next,
        isCpuThinking: false,
        cpuScore: next.status == GameStatus.cpuWon
            ? state.cpuScore + 1
            : state.cpuScore,
      );
      if (next.isComplete) {
        _saveCompletedRound(next);
      }
    });
  }

  void _saveCompletedRound(GameRound round) {
    unawaited(
      _persistCompletedRound(round).onError((_, _) {
        state = state.copyWith(historySaveFailed: true);
      }),
    );
  }

  Future<void> _persistCompletedRound(GameRound round) {
    final completedAt = DateTime.now();
    final outcome = switch (round.status) {
      GameStatus.playerWon => GameOutcome.playerOneWin,
      GameStatus.cpuWon => GameOutcome.playerTwoWin,
      GameStatus.draw => GameOutcome.draw,
      GameStatus.active => throw StateError(
        'Only completed rounds can persist.',
      ),
    };
    final record = GameRecord(
      id: completedAt.microsecondsSinceEpoch.toString(),
      playerOneName: 'You',
      playerTwoName: 'CPU',
      outcome: outcome,
      moveCount: round.cells.whereType<GameMark>().length,
      completedAt: completedAt,
    );
    return ref.read(completeGameUseCaseProvider)(record);
  }
}
