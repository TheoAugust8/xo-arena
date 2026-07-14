import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/domain/entities/game_move_exception.dart';
import 'package:xo_arena/features/game/domain/services/cpu_strategy.dart';
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
    final Game next;
    try {
      next = state.game.applyMove(by: GamePlayer.human, index: index);
    } on GameMoveException {
      return;
    }
    state = state.copyWith(
      game: next,
      playerScore:
          next.status == GameStatus.won && next.winner == GamePlayer.human
          ? state.playerScore + 1
          : state.playerScore,
    );
    if (next.isComplete) {
      _saveCompletedGame(next);
    } else {
      _scheduleCpu();
    }
  }

  void restart() {
    _generation++;
    _cpuTimer?.cancel();
    state = state.copyWith(
      game: Game.initial(),
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
      if (generation != _generation || state.game.isComplete) return;
      final move = CpuStrategyFactory.forDifficulty(
        ref.read(settingsProvider).difficulty,
      ).chooseMove(state.game);
      final next = state.game.applyMove(by: GamePlayer.cpu, index: move);
      state = state.copyWith(
        game: next,
        isCpuThinking: false,
        cpuScore: next.status == GameStatus.won && next.winner == GamePlayer.cpu
            ? state.cpuScore + 1
            : state.cpuScore,
      );
      if (next.isComplete) {
        _saveCompletedGame(next);
      }
    });
  }

  void _saveCompletedGame(Game game) {
    final generation = _generation;
    unawaited(
      _persistCompletedGame(game)
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

  Future<void> _persistCompletedGame(Game game) {
    final settings = ref.read(settingsProvider);
    return ref.read(completeGameUseCaseProvider)(
      game: game,
      difficulty: settings.difficulty,
      skin: settings.skin,
    );
  }
}
