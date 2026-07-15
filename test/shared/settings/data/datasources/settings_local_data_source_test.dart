import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xo_arena/core/constants/app_storage_keys.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/settings/data/datasources/settings_local_data_source.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';

void main() {
  test('returns defaults when stored settings are absent', () async {
    SharedPreferences.setMockInitialValues({});
    final dataSource = SharedPreferencesSettingsLocalDataSource(
      await SharedPreferences.getInstance(),
    );

    expect(await dataSource.load(), AppSettings.defaults);
  });

  test('restores theme and game settings', () async {
    SharedPreferences.setMockInitialValues({
      AppStorageKeys.settings:
          '{"theme":"light","difficulty":"medium","skin":"football","soundEnabled":false}',
    });
    final dataSource = SharedPreferencesSettingsLocalDataSource(
      await SharedPreferences.getInstance(),
    );

    expect(
      await dataSource.load(),
      const AppSettings(
        theme: AppThemePreference.light,
        difficulty: GameDifficulty.medium,
        skin: GameSymbolSkin.football,
        soundEnabled: false,
      ),
    );
  });

  test('restores poker and basketball skins', () async {
    for (final skin in [GameSymbolSkin.poker, GameSymbolSkin.basketball]) {
      SharedPreferences.setMockInitialValues({
        AppStorageKeys.settings:
            '{"theme":"system","difficulty":"hard","skin":"${skin.name}","soundEnabled":true}',
      });
      final dataSource = SharedPreferencesSettingsLocalDataSource(
        await SharedPreferences.getInstance(),
      );

      expect((await dataSource.load()).skin, skin);
    }
  });

  test('returns defaults when stored settings are corrupt', () async {
    SharedPreferences.setMockInitialValues({
      AppStorageKeys.settings: '{not-json',
    });
    final dataSource = SharedPreferencesSettingsLocalDataSource(
      await SharedPreferences.getInstance(),
    );

    expect(await dataSource.load(), AppSettings.defaults);
  });

  test('saves one atomic settings snapshot', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final dataSource = SharedPreferencesSettingsLocalDataSource(preferences);

    await dataSource.save(
      const AppSettings(
        theme: AppThemePreference.light,
        difficulty: GameDifficulty.easy,
        skin: GameSymbolSkin.geometric,
      ),
    );

    expect(
      preferences.getString(AppStorageKeys.settings),
      '{"theme":"light","difficulty":"easy","skin":"geometric","soundEnabled":true}',
    );
  });
}
