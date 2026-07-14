import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/settings/data/models/app_settings_dto.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';

void main() {
  test('maps settings between domain and persisted JSON', () {
    const settings = AppSettings(
      theme: AppThemePreference.light,
      difficulty: GameDifficulty.medium,
      skin: GameSymbolSkin.football,
      soundEnabled: false,
    );

    final dto = AppSettingsDto.fromDomain(settings);

    expect(dto.toJson(), {
      'theme': 'light',
      'difficulty': 'medium',
      'skin': 'football',
      'soundEnabled': false,
    });
    expect(AppSettingsDto.fromJson(dto.toJson()).toDomain(), settings);
  });
}
