import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xo_arena/app/app.dart';
import 'package:xo_arena/app/router.dart';
import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';
import 'package:xo_arena/features/game/presentation/providers/game_sound_provider.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_cell.dart';
import 'package:xo_arena/features/launch/presentation/startup_launch.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/domain/repositories/settings_repository.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';

void main() {
  setUp(() => appRouter.go('/'));

  testWidgets('shows the branded launch sequence before Home', (tester) async {
    await tester.pumpWidget(_TestAppScope(child: const App()));

    await tester.pump();
    expect(find.byKey(const ValueKey('startup_launch')), findsOneWidget);
    expect(find.text('ARENA'), findsOneWidget);
    expect(find.text('PLAY NOW'), findsNothing);

    await tester.pump(launchDuration);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('startup_launch')), findsNothing);
    expect(find.text('PLAY NOW'), findsOneWidget);
  });

  testWidgets('renders the XO Arena home in English', (tester) async {
    await tester.pumpWidget(_TestAppScope(child: const App()));

    await tester.pumpAndSettle();
    expect(find.text('XO ARENA'), findsOneWidget);
    expect(find.text('Prove your edge against the machine.'), findsOneWidget);
    expect(find.text('PLAY NOW'), findsOneWidget);
    expect(find.text('VIEW HISTORY'), findsOneWidget);
  });

  testWidgets('renders the playable Game in English', (tester) async {
    await tester.pumpWidget(_TestAppScope(child: const App()));

    await tester.pumpAndSettle();
    await tester.tap(find.text('PLAY NOW'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('XO ARENA'), findsOneWidget);
    expect(find.text('YOUR TURN'), findsOneWidget);
    expect(find.text('NEW GAME'), findsOneWidget);
  });

  testWidgets('renders the History empty state in English', (tester) async {
    await tester.pumpWidget(_TestAppScope(child: const App()));

    await tester.pumpAndSettle();
    await tester.tap(find.text('VIEW HISTORY'));
    await tester.pumpAndSettle();

    expect(find.text('Match History'), findsOneWidget);
    expect(find.text('No completed games yet.'), findsOneWidget);
    expect(find.text('START PLAYING'), findsOneWidget);
  });

  testWidgets('starts a fresh session after returning Home', (tester) async {
    await tester.pumpWidget(_TestAppScope(child: const App()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PLAY NOW'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byType(GameCell).first);
    await tester.pump();
    expect(
      tester
          .widgetList<GameCell>(find.byType(GameCell))
          .where((cell) => cell.mark != null),
      isNotEmpty,
    );

    await tester.tap(find.byTooltip('Back to Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PLAY NOW'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester
          .widgetList<GameCell>(find.byType(GameCell))
          .where((cell) => cell.mark != null),
      isEmpty,
    );
  });
}

class _TestAppScope extends StatelessWidget {
  const _TestAppScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        gameRecordsProvider.overrideWith((ref) async => []),
        settingsRepositoryProvider.overrideWithValue(
          _MemorySettingsRepository(),
        ),
        gameSoundPlayerProvider.overrideWithValue(_NoOpGameSoundPlayer()),
      ],
      child: child,
    );
  }
}

final class _MemorySettingsRepository implements SettingsRepository {
  AppSettings value = AppSettings.defaults;

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<void> save(AppSettings settings) async {
    value = settings;
  }
}

final class _NoOpGameSoundPlayer implements GameSoundPlayer {
  @override
  Future<void> prepare() async {}

  @override
  Future<void> play(GameSoundCue cue) async {}
}
