import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';

part 'game_sound_provider.g.dart';

@Riverpod(keepAlive: true)
GameSoundPlayer gameSoundPlayer(Ref ref) {
  throw StateError('GameSoundPlayer must be provided by app composition.');
}
