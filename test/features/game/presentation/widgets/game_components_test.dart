import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/core/design_system/app_theme.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_cell.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_score.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_status_badge.dart';
import 'package:xo_arena/l10n/l10n.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/presentation/widgets/settings_sheet.dart';

void main() {
  Widget themed(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme ?? AppTheme.dark,
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('renders every cell variant', (tester) async {
    for (final variant in GameCellVariant.values) {
      await tester.pumpWidget(
        themed(GameCell(variant: variant, onPressed: () {})),
      );
      expect(find.byType(GameCell), findsOneWidget);
    }

    await tester.pumpWidget(themed(const GameCell(variant: GameCellVariant.x)));
    expect(find.text('X'), findsOneWidget);

    await tester.pumpWidget(themed(const GameCell(variant: GameCellVariant.o)));
    expect(find.text('O'), findsOneWidget);

    await tester.pumpWidget(
      themed(const GameCell(variant: GameCellVariant.winning)),
    );
    final materials = tester.widgetList<Material>(find.byType(Material));
    expect(
      materials.map((material) => material.color),
      contains(AppThemeTokens.dark.winBackground),
    );
    expect(find.byType(AnimatedSwitcher), findsOneWidget);
  });

  testWidgets('disables symbol motion when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: GameCell(variant: GameCellVariant.x),
        ),
      ),
    );

    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      Duration.zero,
    );
  });

  testWidgets('exposes one semantic label for cells and status', (
    tester,
  ) async {
    await tester.pumpWidget(themed(const GameCell(variant: GameCellVariant.x)));

    expect(find.bySemanticsLabel('X'), findsOneWidget);

    await tester.pumpWidget(
      themed(const GameStatusBadge(variant: GameStatusVariant.player)),
    );

    expect(find.bySemanticsLabel('YOUR TURN'), findsOneWidget);
  });

  testWidgets('exposes a semantic tap action for an enabled cell', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(GameCell(variant: GameCellVariant.empty, onPressed: () {})),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Empty cell')),
      isSemantics(
        label: 'Empty cell',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('renders status badge labels', (tester) async {
    for (final variant in GameStatusVariant.values) {
      await tester.pumpWidget(themed(GameStatusBadge(variant: variant)));
      await tester.pump(const Duration(milliseconds: 250));
      final context = tester.element(find.byType(GameStatusBadge));
      expect(find.text(variant.label(context.l10n)), findsOneWidget);
    }

    await tester.pumpWidget(
      themed(const GameStatusBadge(variant: GameStatusVariant.player)),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byType(AnimatedSwitcher), findsOneWidget);
    expect(find.byType(GameActivityDot), findsOneWidget);
  });

  testWidgets('animates status changes and respects reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(const GameStatusBadge(variant: GameStatusVariant.player)),
    );
    await tester.pumpWidget(
      themed(const GameStatusBadge(variant: GameStatusVariant.cpu)),
    );
    await tester.pump();

    expect(find.text('CPU THINKING'), findsOneWidget);
    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      const Duration(milliseconds: 200),
    );

    await tester.pumpWidget(
      themed(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: GameStatusBadge(variant: GameStatusVariant.cpu),
        ),
      ),
    );

    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      Duration.zero,
    );
  });

  testWidgets('pulses active status dot while animations are enabled', (
    tester,
  ) async {
    for (final variant in [GameStatusVariant.player, GameStatusVariant.cpu]) {
      await tester.pumpWidget(themed(GameStatusBadge(variant: variant)));
      await tester.pump(const Duration(milliseconds: 500));

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, lessThan(1));
    }
  });

  testWidgets('renders score component', (tester) async {
    await tester.pumpWidget(
      themed(
        const GameScore(
          playerScore: 3,
          cpuScore: 1,
          playerMark: GameSymbolMark.x,
          cpuMark: GameSymbolMark.o,
        ),
      ),
    );

    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('CPU'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('VS'), findsOneWidget);
  });

  testWidgets('renders both score symbols with selected skin', (tester) async {
    await tester.pumpWidget(
      themed(
        const GameScore(
          playerScore: 3,
          cpuScore: 1,
          playerMark: GameSymbolMark.x,
          cpuMark: GameSymbolMark.o,
          skin: GameSymbolSkin.tennis,
        ),
      ),
    );

    final symbols = tester.widgetList<GameSymbol>(find.byType(GameSymbol));
    expect(symbols.map((symbol) => (symbol.mark, symbol.skin)), [
      (GameSymbolMark.x, GameSymbolSkin.tennis),
      (GameSymbolMark.o, GameSymbolSkin.tennis),
    ]);
    expect(find.text('X'), findsNothing);
  });

  testWidgets('renders score symbols from player mapping', (tester) async {
    await tester.pumpWidget(
      themed(
        const GameScore(
          playerScore: 2,
          cpuScore: 4,
          playerMark: GameSymbolMark.o,
          cpuMark: GameSymbolMark.x,
        ),
      ),
    );

    final symbols = tester.widgetList<GameSymbol>(find.byType(GameSymbol));
    expect(symbols.map((symbol) => symbol.mark), [
      GameSymbolMark.o,
      GameSymbolMark.x,
    ]);
  });

  testWidgets('animates score changes and respects reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        const GameScore(
          playerScore: 0,
          cpuScore: 0,
          playerMark: GameSymbolMark.x,
          cpuMark: GameSymbolMark.o,
        ),
      ),
    );
    await tester.pumpWidget(
      themed(
        const GameScore(
          playerScore: 1,
          cpuScore: 0,
          playerMark: GameSymbolMark.x,
          cpuMark: GameSymbolMark.o,
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    expect(
      tester
          .widgetList<AnimatedSwitcher>(find.byType(AnimatedSwitcher))
          .first
          .duration,
      const Duration(milliseconds: 220),
    );

    await tester.pumpWidget(
      themed(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: GameScore(
            playerScore: 1,
            cpuScore: 0,
            playerMark: GameSymbolMark.x,
            cpuMark: GameSymbolMark.o,
          ),
        ),
      ),
    );

    expect(
      tester
          .widgetList<AnimatedSwitcher>(find.byType(AnimatedSwitcher))
          .first
          .duration,
      Duration.zero,
    );
  });

  testWidgets('renders settings variants', (tester) async {
    await tester.pumpWidget(
      themed(
        SettingsSheet(
          settings: const AppSettings(
            theme: AppThemePreference.dark,
            difficulty: GameDifficulty.medium,
            skin: GameSymbolSkin.classic,
          ),
          onThemeChanged: (_) async {},
          onDifficultyChanged: (_) async {},
          onSkinChanged: (_) async {},
          onSoundEnabledChanged: (_) async {},
          onClose: () {},
        ),
      ),
    );

    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('Theme'), findsNothing);
    expect(find.text('System setting'), findsNothing);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('DIFFICULTY'), findsOneWidget);
    expect(find.text('SYMBOL SKIN'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(
      find.text('CPU makes occasional mistakes. A balanced challenge.'),
      findsOneWidget,
    );
    expect(find.byType(SettingsSheet), findsOneWidget);
    expect(find.byKey(const ValueKey('settings_theme_toggle')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('settings_difficulty_rail')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('settings_skin_classic')), findsOneWidget);

    final themeToggle = find.byKey(const ValueKey('settings_theme_toggle'));
    expect(tester.getSize(themeToggle).width, 392);

    final sectionLeft = tester.getTopLeft(find.text('SYMBOL SKIN')).dx;
    final firstSkinLeft = tester
        .getTopLeft(find.byKey(const ValueKey('settings_skin_classic')))
        .dx;
    expect(sectionLeft, firstSkinLeft);

    final sectionBottom = tester.getBottomLeft(find.text('SYMBOL SKIN')).dy;
    final firstSkinTop = tester
        .getTopLeft(find.byKey(const ValueKey('settings_skin_classic')))
        .dy;
    expect(firstSkinTop - sectionBottom, lessThanOrEqualTo(16));

    final selectedSkin = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('settings_skin_classic')),
    );
    final selectedDecoration = selectedSkin.decoration! as BoxDecoration;
    expect(selectedDecoration.border!.top.width, 1.5);
    expect(selectedDecoration.border!.top.color, AppThemeTokens.dark.primary);
  });

  testWidgets('renders sport and poker skins as vector symbols', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        const Row(
          children: [
            GameSymbol(mark: GameSymbolMark.x, skin: GameSymbolSkin.tennis),
            GameSymbol(mark: GameSymbolMark.o, skin: GameSymbolSkin.tennis),
            GameSymbol(mark: GameSymbolMark.x, skin: GameSymbolSkin.football),
            GameSymbol(mark: GameSymbolMark.o, skin: GameSymbolSkin.football),
            GameSymbol(mark: GameSymbolMark.x, skin: GameSymbolSkin.poker),
            GameSymbol(mark: GameSymbolMark.o, skin: GameSymbolSkin.poker),
            GameSymbol(mark: GameSymbolMark.x, skin: GameSymbolSkin.basketball),
            GameSymbol(mark: GameSymbolMark.o, skin: GameSymbolSkin.basketball),
          ],
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(GameSymbol),
        matching: find.byType(CustomPaint),
      ),
      findsNWidgets(8),
    );
  });

  testWidgets('offers six symbol skins', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: Scaffold(
          body: SettingsSheet(
            settings: AppSettings.defaults.copyWith(
              theme: AppThemePreference.dark,
            ),
            onThemeChanged: (_) async {},
            onDifficultyChanged: (_) async {},
            onSkinChanged: (_) async {},
            onSoundEnabledChanged: (_) async {},
            onClose: () {},
          ),
        ),
      ),
    );

    final tennis = find.byKey(const ValueKey('settings_skin_tennis'));
    final football = find.byKey(const ValueKey('settings_skin_football'));
    final poker = find.byKey(const ValueKey('settings_skin_poker'));
    final basketball = find.byKey(const ValueKey('settings_skin_basketball'));

    expect(tennis, findsOneWidget);
    expect(football, findsOneWidget);
    expect(poker, findsOneWidget);
    expect(basketball, findsOneWidget);
    expect(find.text('Poker'), findsOneWidget);
    expect(find.text('Basketball'), findsOneWidget);
    expect(
      find.descendant(of: tennis, matching: find.byType(CustomPaint)),
      findsNWidgets(2),
    );
    expect(
      find.descendant(of: football, matching: find.byType(CustomPaint)),
      findsNWidgets(2),
    );
    expect(
      find.descendant(of: poker, matching: find.byType(CustomPaint)),
      findsNWidgets(2),
    );
    expect(
      find.descendant(of: basketball, matching: find.byType(CustomPaint)),
      findsNWidgets(2),
    );
    final tennisPreview = find.descendant(
      of: tennis,
      matching: find.byType(CustomPaint),
    );
    expect(tester.getSize(tennisPreview.first), const Size.square(30));
  });

  testWidgets('exposes exact actionable settings option semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: Scaffold(
          body: SettingsSheet(
            settings: AppSettings.defaults.copyWith(
              theme: AppThemePreference.dark,
            ),
            onThemeChanged: (_) async {},
            onDifficultyChanged: (_) async {},
            onSkinChanged: (_) async {},
            onSoundEnabledChanged: (_) async {},
            onClose: () {},
          ),
        ),
      ),
    );

    final expectations = [
      (
        find.byKey(const ValueKey('settings_theme_dark')),
        'Dark theme, selected',
      ),
      (
        find.byKey(const ValueKey('settings_difficulty_hard')),
        'Hard difficulty, selected',
      ),
      (
        find.byKey(const ValueKey('settings_skin_classic')),
        'Classic symbol skin, selected',
      ),
    ];
    for (final expectation in expectations) {
      expect(
        tester.getSemantics(expectation.$1),
        isSemantics(
          label: expectation.$2,
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
    }
  });

  testWidgets('forwards shared settings selections', (tester) async {
    AppThemePreference? selectedTheme;
    GameDifficulty? selectedDifficulty;
    GameSymbolSkin? selectedSkin;
    bool? soundEnabled;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: Scaffold(
          body: SettingsSheet(
            settings: AppSettings.defaults.copyWith(
              theme: AppThemePreference.dark,
            ),
            onThemeChanged: (value) async => selectedTheme = value,
            onDifficultyChanged: (value) async => selectedDifficulty = value,
            onSkinChanged: (value) async => selectedSkin = value,
            onSoundEnabledChanged: (value) async => soundEnabled = value,
            onClose: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('settings_theme_light')));
    await tester.tap(find.byKey(const ValueKey('settings_theme_system')));
    await tester.tap(find.byKey(const ValueKey('settings_difficulty_medium')));
    await tester.tap(find.byKey(const ValueKey('settings_skin_tennis')));
    await tester.tap(find.byKey(const ValueKey('settings_sound_toggle')));

    expect(selectedTheme, AppThemePreference.system);
    expect(selectedDifficulty, GameDifficulty.medium);
    expect(selectedSkin, GameSymbolSkin.tennis);
    expect(soundEnabled, isFalse);
  });

  testWidgets('gives the sound control a 48 by 48 touch target', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: Scaffold(
          body: SettingsSheet(
            settings: AppSettings.defaults.copyWith(
              theme: AppThemePreference.dark,
            ),
            onThemeChanged: (_) async {},
            onDifficultyChanged: (_) async {},
            onSkinChanged: (_) async {},
            onSoundEnabledChanged: (_) async {},
            onClose: () {},
          ),
        ),
      ),
    );

    final soundControl = find.byKey(const ValueKey('settings_sound_toggle'));
    expect(
      tester.getSize(
        find.descendant(of: soundControl, matching: find.byType(InkWell)),
      ),
      const Size.square(48),
    );
  });

  testWidgets('fits skin previews on compact screens with large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 568),
            padding: EdgeInsets.only(top: 24, bottom: 34),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            body: SettingsSheet(
              settings: AppSettings.defaults,
              onThemeChanged: _ignoreTheme,
              onDifficultyChanged: _ignoreDifficulty,
              onSkinChanged: _ignoreSkin,
              onSoundEnabledChanged: _ignoreSound,
              onClose: _ignoreClose,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

Future<void> _ignoreTheme(AppThemePreference value) async {}

Future<void> _ignoreDifficulty(GameDifficulty value) async {}

Future<void> _ignoreSkin(GameSymbolSkin value) async {}

Future<void> _ignoreSound(bool value) async {}

void _ignoreClose() {}
