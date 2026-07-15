import 'package:flutter/material.dart';

import 'package:xo_arena/l10n/l10n.dart';
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
  String label(AppLocalizations l10n) => switch (this) {
    GameDifficulty.easy => l10n.difficultyEasy,
    GameDifficulty.medium => l10n.difficultyMedium,
    GameDifficulty.hard => l10n.difficultyHard,
  };

  String description(AppLocalizations l10n) => switch (this) {
    GameDifficulty.easy => l10n.difficultyEasyDescription,
    GameDifficulty.medium => l10n.difficultyMediumDescription,
    GameDifficulty.hard => l10n.difficultyHardDescription,
  };
}

extension GameSymbolSkinUi on GameSymbolSkin {
  String label(AppLocalizations l10n) => switch (this) {
    GameSymbolSkin.classic => l10n.skinClassic,
    GameSymbolSkin.geometric => l10n.skinGeometric,
    GameSymbolSkin.tennis => l10n.skinTennis,
    GameSymbolSkin.football => l10n.skinFootball,
    GameSymbolSkin.poker => l10n.skinPoker,
    GameSymbolSkin.basketball => l10n.skinBasketball,
  };
}
