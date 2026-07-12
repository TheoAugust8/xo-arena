import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:xo_arena/features/game/presentation/game_screen.dart';

void main() {
  testWidgets('shows Game placeholder content', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Game'), findsOneWidget);
    expect(find.text('Temporary screen'), findsOneWidget);
    expect(
      find.text('The board is coming in a dedicated step.'),
      findsOneWidget,
    );
  });

  testWidgets('returns Home from Game', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Home destination'), findsOneWidget);
  });
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/game',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Home destination')),
      ),
      GoRoute(path: '/game', builder: (_, _) => const GameScreen()),
    ],
  );
}
