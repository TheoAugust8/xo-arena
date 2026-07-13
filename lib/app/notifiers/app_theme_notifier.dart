import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xo_arena/app/data/app_theme_local_data_source.dart';

part 'app_theme_notifier.g.dart';

@Riverpod(keepAlive: true)
Future<AppThemeLocalDataSource> appThemeLocalDataSource(Ref ref) async {
  final preferences = await SharedPreferences.getInstance();
  return SharedPreferencesAppThemeLocalDataSource(preferences);
}

@Riverpod(keepAlive: true)
class AppThemeNotifier extends _$AppThemeNotifier {
  var _hasUserSelection = false;
  Future<void> _persistenceQueue = Future.value();

  @override
  ThemeMode build() {
    unawaited(_restore());
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode value) {
    _hasUserSelection = true;
    state = value;
    return _enqueuePersistence(value);
  }

  Future<void> _restore() async {
    final dataSource = await ref.read(appThemeLocalDataSourceProvider.future);
    final storedThemeMode = await dataSource.load();
    if (_hasUserSelection || storedThemeMode == null) return;
    state = storedThemeMode;
  }

  Future<void> _enqueuePersistence(ThemeMode value) {
    final result = _persistenceQueue.then((_) async {
      final dataSource = await ref.read(appThemeLocalDataSourceProvider.future);
      await dataSource.save(value);
    });
    _persistenceQueue = result.catchError((_) {});
    return result;
  }
}
