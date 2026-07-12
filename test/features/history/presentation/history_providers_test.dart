import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xo_arena/features/history/presentation/history_providers.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';

void main() {
  test(
    'shares the provider mutation queue across concurrent deletes',
    () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final repository = container.read(gameRecordRepositoryProvider);
      final first = _record('first');
      final second = _record('second');

      await repository.save(first);
      await repository.save(second);

      await Future.wait([
        repository.delete(first.id),
        repository.delete(second.id),
      ]);

      expect(await repository.getAll(), isEmpty);
    },
  );
}

GameRecord _record(String id) {
  return GameRecord(
    id: id,
    playerOneName: 'X',
    playerTwoName: 'O',
    winnerName: 'X',
    moveCount: 7,
    completedAt: DateTime.utc(2026, 7, 12),
  );
}
