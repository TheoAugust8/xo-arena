import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xo_arena/app/app.dart';
import 'package:xo_arena/app/di/app_provider_scope.dart';
import 'package:xo_arena/app/router.dart';
import 'package:xo_arena/core/constants/app_routes.dart';
import 'package:xo_arena/features/game/application/ports/game_sound_player.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/presentation/game_screen.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_notifier.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_cell.dart';
import 'package:xo_arena/features/home/presentation/home_screen.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appRouter.go(AppRoutes.home);
  });

  testWidgets('completes a match and exposes its persisted History record', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await _pumpApplication(tester, preferences: preferences);

    await tester.tap(find.text('PLAY NOW'));
    await tester.pump(const Duration(milliseconds: 400));
    final gameContainer = ProviderScope.containerOf(
      tester.element(find.byType(GameScreen)),
      listen: false,
    );
    var humanTurns = 0;
    while (!gameContainer.read(gameProvider).game.isComplete) {
      final game = gameContainer.read(gameProvider).game;
      expect(game.currentPlayer, GamePlayer.human);
      final move = game.board.availableMoves.first;
      await tester.tap(find.byType(GameCell).at(move));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      humanTurns++;
      expect(humanTurns, lessThanOrEqualTo(5));
    }
    await tester.pump();

    expect(
      gameContainer.read(gameProvider).game.status,
      isNot(GameStatus.active),
    );

    await tester.tap(find.byKey(const ValueKey('game_back_button')));
    await tester.pumpAndSettle();
    final viewHistoryButton = find.text('VIEW HISTORY');
    await tester.ensureVisible(viewHistoryButton);
    await tester.tap(viewHistoryButton);
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> && key.value.startsWith('history_card_');
      }),
      findsOneWidget,
    );
  });

  testWidgets('restores settings after rebuilding application composition', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await _pumpApplication(tester, preferences: preferences);

    await tester.tap(find.byKey(const ValueKey('home_difficulty_medium')));
    await tester.tap(find.byKey(const ValueKey('home_settings_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings_theme_light')));
    await tester.ensureVisible(
      find.byKey(const ValueKey('settings_skin_football')),
    );
    await tester.tap(find.byKey(const ValueKey('settings_skin_football')));
    await tester.tap(find.byKey(const ValueKey('settings_sound_toggle')));
    await tester.pumpAndSettle();

    expect(
      _settingsFrom(tester),
      const AppSettings(
        theme: AppThemePreference.light,
        difficulty: GameDifficulty.medium,
        skin: GameSymbolSkin.football,
        soundEnabled: false,
      ),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    appRouter.go(AppRoutes.home);
    await _pumpApplication(tester, preferences: preferences);

    expect(
      _settingsFrom(tester),
      const AppSettings(
        theme: AppThemePreference.light,
        difficulty: GameDifficulty.medium,
        skin: GameSymbolSkin.football,
        soundEnabled: false,
      ),
    );
  });
}

Future<void> _pumpApplication(
  WidgetTester tester, {
  required SharedPreferences preferences,
}) async {
  await tester.pumpWidget(
    AppProviderScope(
      preferences: preferences,
      gameSoundPlayer: const _SilentGameSoundPlayer(),
      child: const App(),
    ),
  );
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

AppSettings _settingsFrom(WidgetTester tester) {
  final context = tester.element(find.byType(HomeScreen));
  return ProviderScope.containerOf(
    context,
    listen: false,
  ).read(settingsProvider);
}

final class _SilentGameSoundPlayer implements GameSoundPlayer {
  const _SilentGameSoundPlayer();

  @override
  Future<void> prepare() async {}

  @override
  Future<void> play(GameSoundCue cue) async {}
}
