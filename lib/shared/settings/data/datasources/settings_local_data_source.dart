import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:xo_arena/core/constants/app_storage_keys.dart';
import 'package:xo_arena/shared/settings/data/models/app_settings_dto.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';

abstract interface class SettingsLocalDataSource {
  Future<AppSettings> load();

  Future<void> save(AppSettings settings);
}

final class SharedPreferencesSettingsLocalDataSource
    implements SettingsLocalDataSource {
  const SharedPreferencesSettingsLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<AppSettings> load() async {
    final encoded = _preferences.getString(AppStorageKeys.settings);
    if (encoded == null) return AppSettings.defaults;

    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      return AppSettingsDto.fromJson(json).toDomain();
    } on Object {
      return AppSettings.defaults;
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    final saved = await _preferences.setString(
      AppStorageKeys.settings,
      jsonEncode(AppSettingsDto.fromDomain(settings).toJson()),
    );
    if (!saved) {
      throw StateError('Unable to persist app settings.');
    }
  }
}
