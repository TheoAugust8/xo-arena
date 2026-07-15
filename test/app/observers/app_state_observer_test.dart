import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/app/observers/app_state_observer.dart';

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
