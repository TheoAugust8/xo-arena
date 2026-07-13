import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppThemeLocalDataSource {
  Future<ThemeMode?> load();

  Future<void> save(ThemeMode themeMode);
}

final class SharedPreferencesAppThemeLocalDataSource
    implements AppThemeLocalDataSource {
  const SharedPreferencesAppThemeLocalDataSource(this._preferences);

  static const preferenceKey = 'app_theme_mode';

  final SharedPreferences _preferences;

  @override
  Future<ThemeMode?> load() async {
    return switch (_preferences.getString(preferenceKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }

  @override
  Future<void> save(ThemeMode themeMode) async {
    await _preferences.setString(preferenceKey, themeMode.name);
  }
}
