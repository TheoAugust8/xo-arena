import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/core/design_system/app_theme.dart';
import 'package:xo_arena/features/game/presentation/game_screen.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_cell.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_score.dart';

void main() {
  testWidgets('renders playable board and session score', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const GameScreen()),
      ),
    );

    expect(find.byType(GameCell), findsNWidgets(9));
    expect(find.text('YOUR TURN'), findsOneWidget);
    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('CPU'), findsOneWidget);
  });

  testWidgets('expands board cells across page content width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const GameScreen()),
      ),
    );

    final firstCell = tester.getRect(find.byType(GameCell).first);
    final thirdCell = tester.getRect(find.byType(GameCell).at(2));

    expect(thirdCell.right - firstCell.left, closeTo(360, 1.1));
  });

  testWidgets('keeps new game visible without page scrolling', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const GameScreen()),
      ),
    );

    expect(find.byType(ListView), findsNothing);
    expect(
      tester.getRect(find.text('NEW GAME')).bottom,
      lessThanOrEqualTo(800),
    );
  });

  testWidgets('uses one responsive width for game content', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const GameScreen()),
      ),
    );

    final firstCell = tester.getRect(find.byType(GameCell).first);
    final thirdCell = tester.getRect(find.byType(GameCell).at(2));
    final boardWidth = thirdCell.right - firstCell.left;

    expect(
      tester.getRect(find.byType(GameScore)).width,
      closeTo(boardWidth, 1.1),
    );
    expect(
      tester.getRect(find.widgetWithText(FilledButton, 'NEW GAME')).width,
      closeTo(boardWidth, 1.1),
    );
  });

  testWidgets('scales game content together in compact height', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const GameScreen()),
      ),
    );

    final firstCell = tester.getRect(find.byType(GameCell).first);
    final thirdCell = tester.getRect(find.byType(GameCell).at(2));
    final boardWidth = thirdCell.right - firstCell.left;

    expect(
      tester.getRect(find.byType(GameScore)).width,
      closeTo(boardWidth, 1.1),
    );
    expect(
      tester.getRect(find.widgetWithText(FilledButton, 'NEW GAME')).width,
      closeTo(boardWidth, 1.1),
    );
  });

  testWidgets('uses a touch safe two column layout in landscape', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const GameScreen()),
      ),
    );

    expect(find.byType(FittedBox), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(
      tester.getRect(find.byType(GameCell).first).shortestSide,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getRect(find.text('NEW GAME')).bottom,
      lessThanOrEqualTo(390),
    );
  });

  testWidgets(
    'preserves text scaling with an accessibility overflow fallback',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(400, 700),
                textScaler: TextScaler.linear(2),
              ),
              child: const GameScreen(),
            ),
          ),
        ),
      );

      expect(find.byType(FittedBox), findsNothing);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    },
  );

  testWidgets('locks player input while CPU chooses move', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const GameScreen()),
      ),
    );

    await tester.tap(find.byType(GameCell).first);
    await tester.pump();

    expect(find.text('CPU THINKING'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('YOUR TURN'), findsOneWidget);
  });

  testWidgets('new game clears active board', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const GameScreen()),
      ),
    );

    await tester.tap(find.byType(GameCell).first);
    await tester.pump();
    await tester.tap(find.text('NEW GAME'));
    await tester.pump();

    expect(find.text('YOUR TURN'), findsOneWidget);
  });
}
