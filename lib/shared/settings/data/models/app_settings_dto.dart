import 'package:json_annotation/json_annotation.dart';

import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';

part 'app_settings_dto.g.dart';

@JsonSerializable()
final class AppSettingsDto {
  const AppSettingsDto({
    required this.theme,
    required this.difficulty,
    required this.skin,
    required this.soundEnabled,
  });

  final AppThemePreference theme;
  final GameDifficulty difficulty;
  final GameSymbolSkin skin;
  final bool soundEnabled;

  factory AppSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsDtoFromJson(json);

  factory AppSettingsDto.fromDomain(AppSettings settings) {
    return AppSettingsDto(
      theme: settings.theme,
      difficulty: settings.difficulty,
      skin: settings.skin,
      soundEnabled: settings.soundEnabled,
    );
  }

  Map<String, dynamic> toJson() => _$AppSettingsDtoToJson(this);

  AppSettings toDomain() {
    return AppSettings(
      theme: theme,
      difficulty: difficulty,
      skin: skin,
      soundEnabled: soundEnabled,
    );
  }
}
