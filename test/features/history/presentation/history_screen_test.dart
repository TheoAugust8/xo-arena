import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/core/design_system/app_theme.dart';
import 'package:xo_arena/core/design_system/components/app_icon_control.dart';
import 'package:xo_arena/features/history/presentation/history_screen.dart';
import 'package:xo_arena/l10n/l10n.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

void main() {
  testWidgets('shows an empty state when no games are completed', (
    tester,
  ) async {
    final repository = InMemoryGameRecordRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRecordsProvider.overrideWith((ref) => repository.getAll()),
          gameRecordRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No completed games yet.'), findsOneWidget);
    expect(find.text('START PLAYING'), findsOneWidget);
  });

  testWidgets('shows completed games newest first', (tester) async {
    final repository = InMemoryGameRecordRepository();
    await repository.save(
      _record(
        id: 'older',
        playerOneName: 'Older winner',
        completedAt: DateTime.utc(2026, 7, 11),
      ),
    );
    await repository.save(
      _record(
        id: 'newer',
        playerOneName: 'Newer winner',
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

  testWidgets('builds long history lazily with bounded reveal motion', (
    tester,
  ) async {
    final repository = InMemoryGameRecordRepository();
    for (var index = 0; index < 30; index++) {
      await repository.save(
        _record(
          id: 'game-$index',
          completedAt: DateTime.utc(2026).add(Duration(days: index)),
        ),
      );
    }

    await _pumpHistory(tester, repository);

    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.childrenDelegate, isA<SliverChildBuilderDelegate>());
    expect(
      tester
          .widgetList<TweenAnimationBuilder<double>>(
            find.byType(TweenAnimationBuilder<double>),
          )
          .map((animation) => animation.duration),
      everyElement(lessThanOrEqualTo(const Duration(milliseconds: 420))),
    );
  });

  testWidgets('shows a draw without claiming a winner', (tester) async {
    final repository = InMemoryGameRecordRepository();
    await repository.save(_record(id: 'draw', outcome: GameOutcome.draw));

    await _pumpHistory(tester, repository);

    expect(find.text('DRAW'), findsOneWidget);
    expect(find.text('Draw won'), findsNothing);
  });

  testWidgets('uses a compact history summary', (tester) async {
    final repository = InMemoryGameRecordRepository();
    await repository.save(_record(id: 'win'));
    await repository.save(
      _record(id: 'draw-summary', outcome: GameOutcome.draw),
    );
    await repository.save(
      _record(id: 'loss', outcome: GameOutcome.playerTwoWin),
    );

    await _pumpHistory(tester, repository);

    final summary = find.byKey(const ValueKey('history_summary'));
    expect(summary, findsOneWidget);
    expect(tester.getRect(summary).height, 64);
    expect(find.text('WIN RATE'), findsOneWidget);
    expect(
      find.bySemanticsLabel('1 win, 1 draw, 1 loss, 33% win rate'),
      findsOneWidget,
    );
  });

  testWidgets('uses a compact match card', (tester) async {
    final repository = InMemoryGameRecordRepository();
    await repository.save(_record(id: 'game-1'));

    await _pumpHistory(tester, repository);

    final card = find.byKey(const ValueKey('history_card_game-1'));
    final summary = find.byKey(const ValueKey('history_summary'));
    final symbols = find.byKey(const ValueKey('history_symbols_game-1'));
    expect(card, findsOneWidget);
    expect(tester.getRect(card).height, 68);
    expect(tester.getSize(symbols), const Size(52, 24));
    expect(tester.getTopLeft(card).dy - tester.getBottomLeft(summary).dy, 20);
  });

  testWidgets('shows premium summary and record metadata', (tester) async {
    final repository = InMemoryGameRecordRepository();
    await repository.save(
      _record(
        id: 'game-1',
        difficulty: GameDifficulty.medium,
        skin: GameSymbolSkin.tennis,
      ),
    );

    await _pumpHistory(tester, repository);

    expect(find.text('Match History'), findsOneWidget);
    expect(find.text('WIN RATE'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.textContaining('Medium'), findsOneWidget);
    expect(find.textContaining('Tennis'), findsOneWidget);
    expect(find.textContaining('7 moves'), findsOneWidget);
  });

  testWidgets('uses the shared icon control for clearing history', (
    tester,
  ) async {
    final repository = InMemoryGameRecordRepository();
    await repository.save(_record(id: 'game-1'));

    await _pumpHistory(tester, repository);

    final clear = tester.widget<AppIconControl>(
      find.byKey(const Key('clear-history')),
    );
    expect(clear.icon, Icons.delete_outline_rounded);
    expect(clear.tooltip, 'Clear match history');
    expect(clear.visualSize, 40);
  });

  testWidgets('gives the back control a 48 by 48 touch target', (tester) async {
    await _pumpHistory(tester, InMemoryGameRecordRepository());

    final backControl = find.byTooltip('Back to Home');
    expect(
      tester.getSize(
        find.descendant(of: backControl, matching: find.byType(InkWell)),
      ),
      const Size.square(48),
    );
  });

  testWidgets('deletes an individual completed game', (tester) async {
    final repository = InMemoryGameRecordRepository();
    await repository.save(_record(id: 'game-1'));

    await _pumpHistory(tester, repository);
    await tester.drag(
      find.byKey(const Key('dismiss-game-1')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(await repository.getAll(), isEmpty);
    expect(find.text('No completed games yet.'), findsOneWidget);
  });

  testWidgets('clears all completed games', (tester) async {
    final repository = InMemoryGameRecordRepository();
    await repository.save(_record(id: 'game-1'));
    await repository.save(_record(id: 'game-2', playerOneName: 'Bailey'));

    await _pumpHistory(tester, repository);
    await tester.tap(find.byKey(const Key('clear-history')));
    await tester.pumpAndSettle();
    expect(find.text('Clear all match history?'), findsOneWidget);
    await tester.tap(find.text('CLEAR').last);
    await tester.pumpAndSettle();

    expect(await repository.getAll(), isEmpty);
    expect(find.text('No completed games yet.'), findsOneWidget);
  });

  testWidgets('shows a compact branded clear confirmation', (tester) async {
    final repository = InMemoryGameRecordRepository();
    await repository.save(_record(id: 'game-1'));

    await _pumpHistory(tester, repository);
    await tester.tap(find.byKey(const Key('clear-history')));
    await tester.pumpAndSettle();

    final dialog = find.byKey(const ValueKey('clear_history_dialog'));
    final icon = find.byKey(const ValueKey('clear_history_dialog_icon'));
    final cancel = find.byKey(const ValueKey('cancel_clear_history'));
    final confirm = find.byKey(const ValueKey('confirm_clear_history'));

    expect(dialog, findsOneWidget);
    expect(tester.getSize(dialog).width, lessThanOrEqualTo(360));
    expect(icon, findsOneWidget);
    expect(tester.getSize(cancel).height, 48);
    expect(tester.getSize(confirm).height, 48);
  });

  testWidgets('disables history mutation controls while deleting a game', (
    tester,
  ) async {
    final repository = PendingDeleteGameRecordRepository();
    await repository.save(_record(id: 'game-1'));

    await _pumpHistory(tester, repository);
    await tester.drag(
      find.byKey(const Key('dismiss-game-1')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await repository.deleteStarted.future;
    await tester.pump();

    expect(find.byKey(const ValueKey('history_card_game-1')), findsOneWidget);
    expect(
      tester
          .widget<AppIconControl>(find.byKey(const Key('clear-history')))
          .onPressed,
      isNull,
    );

    repository.completeDelete();
    await tester.pumpAndSettle();
  });

  testWidgets('ignores a second delete while one is pending', (tester) async {
    final repository = ReentrantDeleteGameRecordRepository();
    await repository.save(_record(id: 'game-1'));

    await _pumpHistory(tester, repository);
    final dismissible = tester.widget<Dismissible>(
      find.byKey(const Key('dismiss-game-1')),
    );

    final firstDelete = dismissible.confirmDismiss!(
      DismissDirection.endToStart,
    );
    await repository.deleteStarted.future;
    final secondDelete = dismissible.confirmDismiss!(
      DismissDirection.endToStart,
    );
    await tester.pump();

    expect(repository.deleteCalls, 1);

    repository.completeDelete();
    expect(await firstDelete, isTrue);
    expect(await secondDelete, isFalse);
    await tester.pumpAndSettle();
  });

  testWidgets('ignores a delete completion after screen disposal', (
    tester,
  ) async {
    final repository = PendingDeleteGameRecordRepository();
    await repository.save(_record(id: 'game-1'));

    await _pumpHistory(tester, repository);
    await tester.drag(
      find.byKey(const Key('dismiss-game-1')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await repository.deleteStarted.future;

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SizedBox.shrink(),
      ),
    );
    repository.completeDelete();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('ignores a delete failure after screen disposal', (tester) async {
    final repository = PendingFailingDeleteGameRecordRepository();
    await repository.save(_record(id: 'game-1'));

    await _pumpHistory(tester, repository);
    await tester.drag(
      find.byKey(const Key('dismiss-game-1')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    await repository.deleteStarted.future;

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SizedBox.shrink(),
      ),
    );
    repository.failDelete();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('retries a failed history load', (tester) async {
    final repository = InMemoryGameRecordRepository();
    var shouldFail = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRecordsProvider.overrideWith((ref) async {
            if (shouldFail) throw StateError('load failed');
            return repository.getAll();
          }),
          gameRecordRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load match history.'), findsOneWidget);
    shouldFail = false;
    await tester.tap(find.text('RETRY'));
    await tester.pumpAndSettle();

    expect(find.text('No completed games yet.'), findsOneWidget);
  });

  testWidgets('keeps records and reports a failed delete', (tester) async {
    final repository = FailingDeleteGameRecordRepository();
    await repository.save(_record(id: 'game-1'));

    await _pumpHistory(tester, repository);
    await tester.drag(
      find.byKey(const ValueKey('history_card_game-1')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to delete match.'), findsOneWidget);
    expect(find.byKey(const ValueKey('history_card_game-1')), findsOneWidget);
  });

  testWidgets('supports compact screens with large text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = InMemoryGameRecordRepository();
    await repository.save(
      _record(id: 'game-1', skin: GameSymbolSkin.geometric),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRecordsProvider.overrideWith((ref) => repository.getAll()),
          gameRecordRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(2),
            ),
            child: HistoryScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Match History'), findsOneWidget);
  });

  testWidgets('keeps records and reports a failed clear', (tester) async {
    final repository = FailingClearGameRecordRepository();
    await repository.save(_record(id: 'game-1'));

    await _pumpHistory(tester, repository);
    await tester.tap(find.byKey(const Key('clear-history')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CLEAR').last);
    await tester.pumpAndSettle();

    expect(find.text('Unable to clear match history.'), findsOneWidget);
    expect(find.byKey(const ValueKey('history_card_game-1')), findsOneWidget);
  });

  testWidgets('ignores a clear completion after screen disposal', (
    tester,
  ) async {
    final repository = PendingClearGameRecordRepository();
    await repository.save(_record(id: 'game-1'));

    await _pumpHistory(tester, repository);
    await tester.tap(find.byKey(const Key('clear-history')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CLEAR').last);
    await tester.pump();
    await repository.clearStarted.future;

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SizedBox.shrink(),
      ),
    );
    repository.completeClear();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('ignores a clear failure after screen disposal', (tester) async {
    final repository = PendingFailingClearGameRecordRepository();
    await repository.save(_record(id: 'game-1'));

    await _pumpHistory(tester, repository);
    await tester.tap(find.byKey(const Key('clear-history')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CLEAR').last);
    await tester.pump();
    await repository.clearStarted.future;

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SizedBox.shrink(),
      ),
    );
    repository.failClear();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('centers History in a readable desktop column', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = InMemoryGameRecordRepository();

    await _pumpHistory(tester, repository);

    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'START PLAYING')).width,
      lessThanOrEqualTo(720),
    );
  });
}

Future<void> _pumpHistory(
  WidgetTester tester,
  InMemoryGameRecordRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameRecordsProvider.overrideWith((ref) => repository.getAll()),
        gameRecordRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: const HistoryScreen(),
      ),
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

class PendingFailingDeleteGameRecordRepository
    extends InMemoryGameRecordRepository {
  final deleteStarted = Completer<void>();
  final _deleteCompleter = Completer<void>();

  @override
  Future<void> delete(String id) async {
    deleteStarted.complete();
    await _deleteCompleter.future;
  }

  void failDelete() => _deleteCompleter.completeError(
    StateError('delete failed after disposal'),
  );
}

class ReentrantDeleteGameRecordRepository extends InMemoryGameRecordRepository {
  final deleteStarted = Completer<void>();
  final _deleteCompleter = Completer<void>();
  var deleteCalls = 0;

  @override
  Future<void> delete(String id) async {
    deleteCalls++;
    if (deleteCalls == 1) {
      deleteStarted.complete();
      await _deleteCompleter.future;
    }
    await super.delete(id);
  }

  void completeDelete() => _deleteCompleter.complete();
}

class PendingClearGameRecordRepository extends InMemoryGameRecordRepository {
  final clearStarted = Completer<void>();
  final _clearCompleter = Completer<void>();

  @override
  Future<void> clear() async {
    clearStarted.complete();
    await _clearCompleter.future;
    await super.clear();
  }

  void completeClear() => _clearCompleter.complete();
}

class PendingFailingClearGameRecordRepository
    extends InMemoryGameRecordRepository {
  final clearStarted = Completer<void>();
  final _clearCompleter = Completer<void>();

  @override
  Future<void> clear() async {
    clearStarted.complete();
    await _clearCompleter.future;
  }

  void failClear() =>
      _clearCompleter.completeError(StateError('clear failed after disposal'));
}

class FailingDeleteGameRecordRepository extends InMemoryGameRecordRepository {
  @override
  Future<void> delete(String id) => Future.error(StateError('delete failed'));
}

class FailingClearGameRecordRepository extends InMemoryGameRecordRepository {
  @override
  Future<void> clear() => Future.error(StateError('clear failed'));
}

GameRecord _record({
  required String id,
  String playerOneName = 'Alex',
  GameOutcome outcome = GameOutcome.playerOneWin,
  DateTime? completedAt,
  GameDifficulty difficulty = GameDifficulty.hard,
  GameSymbolSkin skin = GameSymbolSkin.classic,
}) {
  return GameRecord(
    id: id,
    playerOneName: playerOneName,
    playerTwoName: 'Bailey',
    outcome: outcome,
    moveCount: 7,
    completedAt: completedAt ?? DateTime.utc(2026, 7, 12),
    difficulty: difficulty,
    skin: skin,
  );
}
