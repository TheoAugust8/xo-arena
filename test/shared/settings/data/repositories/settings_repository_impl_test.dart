import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/settings/data/datasources/settings_local_data_source.dart';
import 'package:xo_arena/shared/settings/data/repositories/settings_repository_impl.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';

void main() {
  test('delegates reads and writes to local data source', () async {
    final dataSource = _MemorySettingsLocalDataSource();
    final repository = SettingsRepositoryImpl(dataSource);
    final updated = AppSettings.defaults.copyWith(
      theme: AppThemePreference.dark,
      difficulty: GameDifficulty.easy,
    );

    await repository.save(updated);

    expect(await repository.load(), updated);
  });
}

final class _MemorySettingsLocalDataSource implements SettingsLocalDataSource {
  AppSettings value = AppSettings.defaults;

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<void> save(AppSettings settings) async {
    value = settings;
  }
}
