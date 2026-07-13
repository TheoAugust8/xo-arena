import 'package:xo_arena/features/game/domain/game_round.dart';

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
