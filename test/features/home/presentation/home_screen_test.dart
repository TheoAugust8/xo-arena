import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:xo_arena/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('shows Home actions', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('XO Arena'), findsOneWidget);
    expect(find.text('Open Game'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });

  testWidgets('opens Game from Home', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Open Game'));
    await tester.pumpAndSettle();

    expect(find.text('Game destination'), findsOneWidget);
  });

  testWidgets('opens History from Home', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('History destination'), findsOneWidget);
  });
}

GoRouter _router() {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/game',
        builder: (_, _) => const Scaffold(body: Text('Game destination')),
      ),
      GoRoute(
        path: '/history',
        builder: (_, _) => const Scaffold(body: Text('History destination')),
      ),
    ],
  );
}
