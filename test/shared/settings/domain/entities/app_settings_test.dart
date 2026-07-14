import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';

void main() {
  test('uses hard difficulty and classic skin by default', () {
    expect(
      AppSettings.defaults,
      const AppSettings(
        theme: AppThemePreference.system,
        difficulty: GameDifficulty.hard,
        skin: GameSymbolSkin.classic,
      ),
    );
  });

  test('creates immutable preference updates', () {
    final updated = AppSettings.defaults.copyWith(
      difficulty: GameDifficulty.easy,
      skin: GameSymbolSkin.football,
    );

    expect(updated.difficulty, GameDifficulty.easy);
    expect(updated.skin, GameSymbolSkin.football);
    expect(updated.soundEnabled, isTrue);
    expect(updated.theme, AppThemePreference.system);
    expect(AppSettings.defaults.difficulty, GameDifficulty.hard);
  });

  test('enables sound by default and creates a disabled copy', () {
    expect(AppSettings.defaults.soundEnabled, isTrue);

    expect(
      AppSettings.defaults.copyWith(soundEnabled: false).soundEnabled,
      isFalse,
    );
  });
}
