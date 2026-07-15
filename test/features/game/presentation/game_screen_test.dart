import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';
import 'package:xo_arena/features/game/presentation/providers/game_sound_provider.dart';
import 'package:xo_arena/core/design_system/app_theme.dart';
import 'package:xo_arena/features/game/presentation/game_screen.dart';
import 'package:xo_arena/l10n/l10n.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_cell.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_score.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/domain/repositories/settings_repository.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';

void main() {
  testWidgets('renders playable board and session score', (tester) async {
    await tester.pumpWidget(
      _GameTestScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const GameScreen(),
        ),
      ),
    );

    expect(find.byType(GameCell), findsNWidgets(9));
    expect(find.text('YOUR TURN'), findsOneWidget);
    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('CPU'), findsOneWidget);
    expect(find.byTooltip('Back to Home'), findsOneWidget);
    expect(find.byKey(const ValueKey('game_settings_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('game_difficulty_badge')), findsOneWidget);
    expect(find.bySemanticsLabel('Hard difficulty'), findsOneWidget);
  });

  testWidgets('expands board cells across page content width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _GameTestScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const GameScreen(),
        ),
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
      _GameTestScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const GameScreen(),
        ),
      ),
    );

    expect(find.byType(ListView), findsNothing);
    expect(
      tester.getRect(find.text('NEW GAME')).bottom,
      lessThanOrEqualTo(800),
    );
  });

  testWidgets('fits the iPhone 17 portrait content constraints', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(398, 778));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _GameTestScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const GameScreen(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(
      tester.getRect(find.text('NEW GAME')).bottom,
      lessThanOrEqualTo(778),
    );
  });

  testWidgets('uses one responsive width for game content', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _GameTestScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const GameScreen(),
        ),
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
      _GameTestScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const GameScreen(),
        ),
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
      _GameTestScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const GameScreen(),
        ),
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
        _GameTestScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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
      _GameTestScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const GameScreen(),
        ),
      ),
    );

    await tester.tap(find.byType(GameCell).first);
    await tester.pump();

    expect(find.text('CPU THINKING'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('CPU THINKING'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('YOUR TURN'), findsOneWidget);
  });

  testWidgets('plays a cue when the Human places a mark', (tester) async {
    final sounds = _RecordingGameSoundPlayer();
    await tester.pumpWidget(
      _GameTestScope(
        gameSoundPlayer: sounds,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const GameScreen(),
        ),
      ),
    );

    await tester.tap(find.byType(GameCell).first);
    await tester.pump();

    expect(sounds.played, [GameSoundCue.playerMove]);
  });

  testWidgets('keeps gameplay silent when sound is disabled', (tester) async {
    final sounds = _RecordingGameSoundPlayer();
    await tester.pumpWidget(
      _GameTestScope(
        gameSoundPlayer: sounds,
        settings: AppSettings.defaults.copyWith(soundEnabled: false),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const GameScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byType(GameCell).first);
    await tester.pump();

    expect(sounds.played, isEmpty);
  });

  testWidgets('disables New Game until a game is complete', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _GameTestScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          home: const GameScreen(),
        ),
      ),
    );

    final button = find.byKey(const ValueKey('game_new_game_button'));
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    await tester.tap(find.byType(GameCell).first);
    await tester.pump();

    expect(tester.widget<FilledButton>(button).onPressed, isNull);
  });
}

class _GameTestScope extends StatelessWidget {
  const _GameTestScope({
    required this.child,
    this.gameSoundPlayer,
    this.settings = AppSettings.defaults,
  });

  final Widget child;
  final GameSoundPlayer? gameSoundPlayer;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          _MemorySettingsRepository(settings),
        ),
        gameSoundPlayerProvider.overrideWithValue(
          gameSoundPlayer ?? _RecordingGameSoundPlayer(),
        ),
      ],
      child: child,
    );
  }
}

final class _RecordingGameSoundPlayer implements GameSoundPlayer {
  final played = <GameSoundCue>[];

  @override
  Future<void> prepare() async {}

  @override
  Future<void> play(GameSoundCue cue) async => played.add(cue);
}

final class _MemorySettingsRepository implements SettingsRepository {
  _MemorySettingsRepository([this.preferences = AppSettings.defaults]);

  AppSettings preferences;

  @override
  Future<AppSettings> load() async => preferences;

  @override
  Future<void> save(AppSettings value) async => preferences = value;
}
