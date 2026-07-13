import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xo_arena/app/data/app_theme_local_data_source.dart';
import 'package:xo_arena/app/notifiers/app_theme_notifier.dart';

void main() {
  test('uses system theme mode when no preference exists', () {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(appThemeProvider), ThemeMode.system);
  });

  test('restores persisted theme mode', () async {
    SharedPreferences.setMockInitialValues({
      'app_theme_mode': ThemeMode.light.name,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(appThemeProvider);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(appThemeProvider), ThemeMode.light);
  });

  test('persists selected theme mode', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(appThemeProvider.notifier)
        .setThemeMode(ThemeMode.light);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('app_theme_mode'), ThemeMode.light.name);
  });

  test('serializes consecutive theme selections', () async {
    final dataSource = _OrderedThemeLocalDataSource();
    final container = ProviderContainer(
      overrides: [
        appThemeLocalDataSourceProvider.overrideWith((ref) async => dataSource),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(appThemeProvider.notifier);

    final firstWrite = notifier.setThemeMode(ThemeMode.light);
    await dataSource.firstWriteStarted.future;
    final secondWrite = notifier.setThemeMode(ThemeMode.dark);
    dataSource.releaseFirstWrite();
    await Future.wait([firstWrite, secondWrite]);

    expect(dataSource.savedThemeModes, [ThemeMode.light, ThemeMode.dark]);
  });
}

final class _OrderedThemeLocalDataSource implements AppThemeLocalDataSource {
  final firstWriteStarted = Completer<void>();
  final _firstWriteRelease = Completer<void>();
  final savedThemeModes = <ThemeMode>[];
  var _writeCount = 0;

  @override
  Future<ThemeMode?> load() async => null;

  @override
  Future<void> save(ThemeMode themeMode) async {
    _writeCount++;
    if (_writeCount == 1) {
      firstWriteStarted.complete();
      await _firstWriteRelease.future;
    }
    savedThemeModes.add(themeMode);
  }

  void releaseFirstWrite() => _firstWriteRelease.complete();
}
