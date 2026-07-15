import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

part 'app_settings.freezed.dart';

enum AppThemePreference { system, light, dark }

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(AppThemePreference.system) AppThemePreference theme,
    required GameDifficulty difficulty,
    required GameSymbolSkin skin,
    @Default(true) bool soundEnabled,
  }) = _AppSettings;

  static const defaults = AppSettings(
    difficulty: GameDifficulty.hard,
    skin: GameSymbolSkin.classic,
  );
}
