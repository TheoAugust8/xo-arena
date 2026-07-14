import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';

abstract interface class SettingsLocalDataSource {
  Future<AppSettings> load();

  Future<void> save(AppSettings settings);
}

final class SharedPreferencesSettingsLocalDataSource
    implements SettingsLocalDataSource {
  const SharedPreferencesSettingsLocalDataSource(this._preferences);

  static const settingsKey = 'app_settings';

  final SharedPreferences _preferences;

  @override
  Future<AppSettings> load() async {
    final encoded = _preferences.getString(settingsKey);
    if (encoded == null) return AppSettings.defaults;

    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      return AppSettings(
        theme: AppThemePreference.values.byName(json['theme'] as String),
        difficulty: GameDifficulty.values.byName(json['difficulty'] as String),
        skin: GameSymbolSkin.values.byName(json['skin'] as String),
        soundEnabled: json['soundEnabled'] as bool,
      );
    } on Object {
      return AppSettings.defaults;
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    final saved = await _preferences.setString(
      settingsKey,
      jsonEncode({
        'theme': settings.theme.name,
        'difficulty': settings.difficulty.name,
        'skin': settings.skin.name,
        'soundEnabled': settings.soundEnabled,
      }),
    );
    if (!saved) {
      throw StateError('Unable to persist app settings.');
    }
  }
}
