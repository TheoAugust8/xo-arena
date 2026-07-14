import 'package:flutter/material.dart';

import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';

extension AppThemePreferenceUi on AppThemePreference {
  ThemeMode get materialThemeMode => switch (this) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
}

extension GameDifficultyUi on GameDifficulty {
  String get label => switch (this) {
    GameDifficulty.easy => 'Easy',
    GameDifficulty.medium => 'Medium',
    GameDifficulty.hard => 'Hard',
  };

  String get description => switch (this) {
    GameDifficulty.easy => 'CPU plays randomly. Perfect for beginners.',
    GameDifficulty.medium =>
      'CPU makes occasional mistakes. A balanced challenge.',
    GameDifficulty.hard => 'CPU plays optimally. Best outcome is a draw.',
  };
}

extension GameSymbolSkinUi on GameSymbolSkin {
  String get label => switch (this) {
    GameSymbolSkin.classic => 'Classic',
    GameSymbolSkin.geometric => 'Geometric',
    GameSymbolSkin.tennis => 'Tennis',
    GameSymbolSkin.football => 'Football',
    GameSymbolSkin.poker => 'Poker',
    GameSymbolSkin.basketball => 'Basketball',
  };
}
