import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xo_arena/app/app.dart';
import 'package:xo_arena/app/router.dart';
import 'package:xo_arena/features/history/presentation/history_providers.dart';

void main() {
  setUp(() => appRouter.go('/'));

  testWidgets('renders the XO Arena home in English', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: XoArenaApp()));

    expect(find.text('XO Arena'), findsOneWidget);
    expect(find.text('Foundations ready'), findsOneWidget);
    expect(
      find.text('Temporary navigation, tic tac toe is coming soon.'),
      findsOneWidget,
    );
    expect(find.text('Open Game'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });

  testWidgets('renders the Game placeholder in English', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: XoArenaApp()));

    await tester.tap(find.text('Open Game'));
    await tester.pumpAndSettle();

    expect(find.text('Game'), findsOneWidget);
    expect(find.text('Temporary screen'), findsOneWidget);
    expect(
      find.text('The board is coming in a dedicated step.'),
      findsOneWidget,
    );
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('renders the History empty state in English', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [gameHistoryProvider.overrideWith((ref) async => [])],
        child: const XoArenaApp(),
      ),
    );

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('No completed games yet.'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });
}
