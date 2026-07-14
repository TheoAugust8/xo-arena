import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xo_arena/core/design_system/app_theme.dart';
import 'package:xo_arena/features/launch/presentation/startup_launch.dart';

void main() {
  testWidgets('skips the launch sequence when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: StartupLaunch(child: Text('Home content')),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('startup_launch')), findsNothing);
    expect(find.text('Home content'), findsOneWidget);
  });

  testWidgets('exposes the launch screen as one semantic container', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const StartupLaunch(child: Text('Home content')),
      ),
    );

    expect(find.bySemanticsLabel('XO Arena launch screen'), findsOneWidget);
    expect(find.text('Home content'), findsNothing);
  });

  testWidgets('shows a visible loading track and animates its fill', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const StartupLaunch(child: Text('Home content')),
      ),
    );

    final trackFinder = find.byKey(const ValueKey('launch_loading_track'));
    final fillFinder = find.byKey(const ValueKey('launch_loading_fill'));
    final fillPaintFinder = find.byKey(
      const ValueKey('launch_loading_fill_paint'),
    );

    expect(tester.getSize(trackFinder), const Size(88, 3));

    await tester.pump(const Duration(milliseconds: 1900));

    final fill = tester.widget<FractionallySizedBox>(fillFinder);
    expect(fill.widthFactor, greaterThan(0));
    expect(fill.widthFactor, lessThan(1));
    expect(tester.getSize(fillPaintFinder).width, greaterThan(0));
    expect(tester.getSize(fillPaintFinder).width, lessThan(88));

    await tester.pump(const Duration(milliseconds: 850));

    final completedFill = tester.widget<FractionallySizedBox>(fillFinder);
    expect(completedFill.widthFactor, closeTo(1, 0.01));
  });

  testWidgets('moves a red progress indicator across the loading track', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const StartupLaunch(child: Text('Home content')),
      ),
    );

    final indicatorFinder = find.byKey(
      const ValueKey('launch_loading_indicator'),
    );

    await tester.pump(const Duration(milliseconds: 1600));
    final start = tester.getCenter(indicatorFinder);

    await tester.pump(const Duration(milliseconds: 600));
    final later = tester.getCenter(indicatorFinder);

    expect(later.dx, greaterThan(start.dx + 20));
  });
}
