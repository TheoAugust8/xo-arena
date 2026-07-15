import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/app/observers/app_state_observer.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_state.dart';

void main() {
  test('wires a debug state observer into the root provider scope', () {
    final observer = File('lib/app/observers/app_state_observer.dart');
    final providerScope = File(
      'lib/app/di/app_provider_scope.dart',
    ).readAsStringSync();

    expect(observer.existsSync(), isTrue);
    expect(providerScope, contains('observers:'));
  });

  test('logs provider additions and state changes', () {
    final messages = <String>[];
    final container = ProviderContainer(
      observers: [AppStateObserver.withSink(messages.add)],
    );
    addTearDown(container.dispose);

    expect(container.read(_counterProvider), 0);
    container.read(_counterProvider.notifier).increment();

    expect(messages, contains('[Riverpod] add counter: 0'));
    expect(messages, contains('[Riverpod] update counter: 0 -> 1'));
  });

  test('logs game state updates as compact field changes', () {
    final messages = <String>[];
    final container = ProviderContainer(
      observers: [AppStateObserver.withSink(messages.add)],
    );
    addTearDown(container.dispose);

    final initial = container.read(_gameStateProvider);
    container
        .read(_gameStateProvider.notifier)
        .replace(
          initial.copyWith(
            game: initial.game.applyMove(by: GamePlayer.human, index: 4),
            isCpuThinking: true,
          ),
        );

    expect(
      messages,
      contains(
        '[Riverpod] update gameState:\n'
        '  board: .../.../... -> .../.X./...\n'
        '  currentPlayer: human -> cpu\n'
        '  isCpuThinking: false -> true',
      ),
    );
  });

  test('logs durations in milliseconds', () {
    final messages = <String>[];
    final container = ProviderContainer(
      observers: [AppStateObserver.withSink(messages.add)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(_durationProvider),
      const Duration(milliseconds: 900),
    );
    expect(messages, contains('[Riverpod] add duration: 900 ms'));
  });
}

final _counterProvider = NotifierProvider<_Counter, int>(
  _Counter.new,
  name: 'counter',
);

final class _Counter extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final _gameStateProvider = NotifierProvider<_GameStateNotifier, GameState>(
  _GameStateNotifier.new,
  name: 'gameState',
);

final class _GameStateNotifier extends Notifier<GameState> {
  @override
  GameState build() => GameState.initial();

  void replace(GameState next) => state = next;
}

final _durationProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 900),
  name: 'duration',
);
