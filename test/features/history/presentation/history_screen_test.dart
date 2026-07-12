import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xo_arena/features/history/presentation/history_providers.dart';
import 'package:xo_arena/features/history/presentation/history_screen.dart';
import 'package:xo_arena/features/history/usecases/clear_history.dart';
import 'package:xo_arena/features/history/usecases/delete_game_record.dart';
import 'package:xo_arena/features/history/usecases/get_history.dart';
import 'package:xo_arena/shared/game_records/domain/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/game_record_repository.dart';

void main() {
  testWidgets('shows an empty state when no games are completed', (
    tester,
  ) async {
    final repository = InMemoryGameRecordRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getHistoryUseCaseProvider.overrideWithValue(
            GetHistoryUseCase(repository),
          ),
          deleteGameRecordUseCaseProvider.overrideWithValue(
            DeleteGameRecordUseCase(repository),
          ),
          clearHistoryUseCaseProvider.overrideWithValue(
            ClearHistoryUseCase(repository),
          ),
        ],
        child: const MaterialApp(home: HistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No completed games yet.'), findsOneWidget);
  });

  testWidgets('shows completed games newest first', (tester) async {
    final repository = InMemoryGameRecordRepository();
    await repository.save(
      _record(
        id: 'older',
        winnerName: 'Older winner',
        completedAt: DateTime.utc(2026, 7, 11),
      ),
    );
    await repository.save(
      _record(
        id: 'newer',
        winnerName: 'Newer winner',
        completedAt: DateTime.utc(2026, 7, 12),
      ),
    );

    await _pumpHistory(tester, repository);

    expect(find.text('Newer winner won'), findsOneWidget);
    expect(find.text('Older winner won'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Newer winner won')).dy,
      lessThan(tester.getTopLeft(find.text('Older winner won')).dy),
    );
  });

  testWidgets('deletes an individual completed game', (tester) async {
    final repository = InMemoryGameRecordRepository();
    await repository.save(_record(id: 'game-1', winnerName: 'Alex'));

    await _pumpHistory(tester, repository);
    await tester.tap(find.byKey(const Key('delete-game-1')));
    await tester.pumpAndSettle();

    expect(await repository.getAll(), isEmpty);
    expect(find.text('No completed games yet.'), findsOneWidget);
  });

  testWidgets('clears all completed games', (tester) async {
    final repository = InMemoryGameRecordRepository();
    await repository.save(_record(id: 'game-1', winnerName: 'Alex'));
    await repository.save(_record(id: 'game-2', winnerName: 'Bailey'));

    await _pumpHistory(tester, repository);
    await tester.tap(find.byKey(const Key('clear-history')));
    await tester.pumpAndSettle();

    expect(await repository.getAll(), isEmpty);
    expect(find.text('No completed games yet.'), findsOneWidget);
  });

  testWidgets('disables history mutation controls while deleting a game', (
    tester,
  ) async {
    final repository = PendingDeleteGameRecordRepository();
    await repository.save(_record(id: 'game-1', winnerName: 'Alex'));

    await _pumpHistory(tester, repository);
    await tester.tap(find.byKey(const Key('delete-game-1')));
    await repository.deleteStarted.future;
    await tester.pump();

    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('delete-game-1')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('clear-history')))
          .onPressed,
      isNull,
    );

    repository.completeDelete();
    await tester.pumpAndSettle();
  });
}

Future<void> _pumpHistory(
  WidgetTester tester,
  InMemoryGameRecordRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        getHistoryUseCaseProvider.overrideWithValue(
          GetHistoryUseCase(repository),
        ),
        deleteGameRecordUseCaseProvider.overrideWithValue(
          DeleteGameRecordUseCase(repository),
        ),
        clearHistoryUseCaseProvider.overrideWithValue(
          ClearHistoryUseCase(repository),
        ),
      ],
      child: const MaterialApp(home: HistoryScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

class InMemoryGameRecordRepository implements GameRecordRepository {
  final List<GameRecord> _records = [];

  @override
  Future<void> clear() async {
    _records.clear();
  }

  @override
  Future<void> delete(String id) async {
    _records.removeWhere((record) => record.id == id);
  }

  @override
  Future<List<GameRecord>> getAll() async => List.of(_records);

  @override
  Future<void> save(GameRecord record) async {
    _records.removeWhere((existingRecord) => existingRecord.id == record.id);
    _records.add(record);
  }
}

class PendingDeleteGameRecordRepository extends InMemoryGameRecordRepository {
  final deleteStarted = Completer<void>();
  final _deleteCompleter = Completer<void>();

  @override
  Future<void> delete(String id) async {
    deleteStarted.complete();
    await _deleteCompleter.future;
    await super.delete(id);
  }

  void completeDelete() => _deleteCompleter.complete();
}

GameRecord _record({
  required String id,
  required String winnerName,
  DateTime? completedAt,
}) {
  return GameRecord(
    id: id,
    playerOneName: 'Alex',
    playerTwoName: 'Bailey',
    winnerName: winnerName,
    moveCount: 7,
    completedAt: completedAt ?? DateTime.utc(2026, 7, 12),
  );
}
