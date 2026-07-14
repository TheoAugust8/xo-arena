import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:xo_arena/features/game/domain/services/cpu_strategy.dart';
import 'package:xo_arena/features/game/domain/services/game_rules.dart';
import 'package:xo_arena/features/game/domain/entities/game_round.dart';
import 'package:xo_arena/features/game/domain/usecases/complete_game.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_state.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';

part 'game_notifier.g.dart';

@riverpod
Duration cpuTurnDelay(Ref ref) => const Duration(milliseconds: 900);

@Riverpod(keepAlive: true)
CompleteGameUseCase completeGameUseCase(Ref ref) {
  return CompleteGameUseCase(ref.read(gameRecordRepositoryProvider));
}

@riverpod
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

  Future<void> setDifficulty(GameDifficulty value) {
    return ref.read(settingsProvider.notifier).setDifficulty(value);
  }

  Future<void> setSkin(GameSymbolSkin value) {
    return ref.read(settingsProvider.notifier).setSkin(value);
  }

  void _scheduleCpu() {
    final generation = ++_generation;
    state = state.copyWith(isCpuThinking: true);
    _cpuTimer?.cancel();
    _cpuTimer = Timer(ref.read(cpuTurnDelayProvider), () {
      if (generation != _generation || state.round.isComplete) return;
      final move = CpuStrategyFactory.forDifficulty(
        ref.read(settingsProvider).difficulty,
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
    final generation = _generation;
    unawaited(
      _persistCompletedRound(round)
          .then((_) {
            if (!ref.mounted) return;
            ref.invalidate(gameRecordsProvider);
          })
          .onError((_, _) {
            if (!ref.mounted || generation != _generation) return;
            state = state.copyWith(historySaveFailed: true);
          }),
    );
  }

  Future<void> _persistCompletedRound(GameRound round) {
    final settings = ref.read(settingsProvider);
    return ref.read(completeGameUseCaseProvider)(
      round: round,
      difficulty: settings.difficulty,
      skin: settings.skin,
    );
  }
}
