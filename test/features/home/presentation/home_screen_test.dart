import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:xo_arena/core/design_system/app_theme.dart';
import 'package:xo_arena/features/home/presentation/home_screen.dart';
import 'package:xo_arena/l10n/l10n.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/domain/repositories/settings_repository.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';

void main() {
  testWidgets('shows Home actions', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await _pumpHome(tester, router);

    expect(find.text('XO ARENA'), findsOneWidget);
    expect(find.text('Prove your edge against the machine.'), findsOneWidget);
    expect(find.text('PLAY NOW'), findsOneWidget);
    expect(find.text('VIEW HISTORY'), findsOneWidget);
    expect(find.bySemanticsLabel('XO Arena logo'), findsOneWidget);
  });

  testWidgets('shows real history summary', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await _pumpHome(
      tester,
      router,
      records: [
        _record('win', GameOutcome.playerOneWin),
        _record('draw', GameOutcome.draw),
        _record('loss', GameOutcome.playerTwoWin),
      ],
    );

    expect(find.text('WINS'), findsOneWidget);
    expect(find.text('DRAWS'), findsOneWidget);
    expect(find.text('LOSSES'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(3));
  });

  testWidgets('uses a compact difficulty rail', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await _pumpHome(tester, router);

    final rail = find.byKey(const ValueKey('home_difficulty_rail'));
    expect(rail, findsOneWidget);
    expect(tester.getRect(rail).height, 40);
    expect(find.byKey(const ValueKey('home_difficulty_hard')), findsOneWidget);
    expect(
      tester.getSemantics(find.byKey(const ValueKey('home_difficulty_hard'))),
      isSemantics(
        label: 'Hard difficulty, selected',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('opens shared settings', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await _pumpHome(tester, router);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('DIFFICULTY'), findsAtLeastNWidgets(1));
    expect(find.text('SYMBOL SKIN'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('persists every shared settings selection', (tester) async {
    final router = _router();
    final repository = _MemorySettingsRepository();
    addTearDown(router.dispose);

    await _pumpHome(tester, router, settingsRepository: repository);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('settings_theme_light')));
    await tester.tap(find.byKey(const ValueKey('settings_difficulty_medium')));
    await tester.tap(find.byKey(const ValueKey('settings_skin_football')));
    await tester.tap(find.byKey(const ValueKey('settings_sound_toggle')));
    await tester.pumpAndSettle();

    expect(
      repository.value,
      const AppSettings(
        theme: AppThemePreference.light,
        difficulty: GameDifficulty.medium,
        skin: GameSymbolSkin.football,
        soundEnabled: false,
      ),
    );
  });

  testWidgets('pins actions beneath a centered Home hero', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = _router();
    addTearDown(router.dispose);

    await _pumpHome(tester, router);

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(
      tester.getRect(find.widgetWithText(FilledButton, 'PLAY NOW')).height,
      56,
    );
    expect(
      tester
          .getRect(find.widgetWithText(OutlinedButton, 'VIEW HISTORY'))
          .height,
      48,
    );
    expect(
      tester
          .getRect(find.widgetWithText(OutlinedButton, 'VIEW HISTORY'))
          .bottom,
      lessThanOrEqualTo(828),
    );
  });

  testWidgets('uses the shared settings control', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await _pumpHome(tester, router);

    expect(find.byKey(const ValueKey('home_settings_button')), findsOneWidget);
    expect(tester.getSize(find.byTooltip('Settings')), const Size(48, 48));
    expect(
      tester.getSize(
        find.descendant(
          of: find.byTooltip('Settings'),
          matching: find.byType(InkWell),
        ),
      ),
      const Size.square(48),
    );
  });

  testWidgets('supports compact screens with large text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRecordsProvider.overrideWith((ref) async => []),
          settingsRepositoryProvider.overrideWithValue(
            _MemorySettingsRepository(),
          ),
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
            child: HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('PLAY NOW'), findsOneWidget);
  });

  testWidgets('fits history stats on compact screens with large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRecordsProvider.overrideWith(
            (ref) async => [_record('win', GameOutcome.playerOneWin)],
          ),
          settingsRepositoryProvider.overrideWithValue(
            _MemorySettingsRepository(),
          ),
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
            child: HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('WINS'), findsOneWidget);
  });

  testWidgets('reports preference persistence failures', (tester) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRecordsProvider.overrideWith((ref) async => []),
          settingsRepositoryProvider.overrideWithValue(
            _FailingSettingsRepository(),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Easy'));
    await tester.pumpAndSettle();

    expect(find.text('Unable to save settings.'), findsOneWidget);
  });

  testWidgets('opens Game from Home', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await _pumpHome(tester, router);
    await tester.tap(find.text('PLAY NOW'));
    await tester.pumpAndSettle();

    expect(find.text('Game destination'), findsOneWidget);
  });

  testWidgets('opens History from Home', (tester) async {
    final router = _router();
    addTearDown(router.dispose);

    await _pumpHome(tester, router);
    await tester.tap(find.text('VIEW HISTORY'));
    await tester.pumpAndSettle();

    expect(find.text('History destination'), findsOneWidget);
  });
}

Future<void> _pumpHome(
  WidgetTester tester,
  GoRouter router, {
  List<GameRecord> records = const [],
  SettingsRepository? settingsRepository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameRecordsProvider.overrideWith((ref) async => records),
        settingsRepositoryProvider.overrideWithValue(
          settingsRepository ?? _MemorySettingsRepository(),
        ),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

GameRecord _record(String id, GameOutcome outcome) => GameRecord(
  id: id,
  playerOneName: 'You',
  playerTwoName: 'CPU',
  outcome: outcome,
  moveCount: 7,
  completedAt: DateTime.utc(2026, 7, 13),
  difficulty: GameDifficulty.hard,
  skin: GameSymbolSkin.classic,
);

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

final class _FailingSettingsRepository implements SettingsRepository {
  @override
  Future<AppSettings> load() async => AppSettings.defaults;

  @override
  Future<void> save(AppSettings preferences) {
    return Future.error(StateError('save failed'));
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
