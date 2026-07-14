import 'package:xo_arena/shared/settings/data/datasources/settings_local_data_source.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/domain/repositories/settings_repository.dart';

final class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<AppSettings> load() => _localDataSource.load();

  @override
  Future<void> save(AppSettings settings) => _localDataSource.save(settings);
}
