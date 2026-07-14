import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xo_arena/features/game/data/audio/synthesized_game_sound_player.dart';
import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';
import 'package:xo_arena/features/game/presentation/providers/game_sound_provider.dart';
import 'package:xo_arena/shared/game_records/data/datasources/shared_preferences_game_record_local_data_source.dart';
import 'package:xo_arena/shared/game_records/data/repositories/game_record_repository_impl.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';
import 'package:xo_arena/shared/settings/data/datasources/settings_local_data_source.dart';
import 'package:xo_arena/shared/settings/data/repositories/settings_repository_impl.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';

class AppProviderScope extends StatefulWidget {
  const AppProviderScope({
    required this.preferences,
    required this.child,
    this.gameSoundPlayer,
    super.key,
  });

  final SharedPreferences preferences;
  final Widget child;
  final GameSoundPlayer? gameSoundPlayer;

  @override
  State<AppProviderScope> createState() => _AppProviderScopeState();
}

class _AppProviderScopeState extends State<AppProviderScope> {
  late final SettingsRepositoryImpl _settingsRepository;
  late final GameRecordRepositoryImpl _gameRecordRepository;
  late final GameSoundPlayer _gameSoundPlayer;
  SynthesizedGameSoundPlayer? _ownedGameSoundPlayer;

  @override
  void initState() {
    super.initState();
    _settingsRepository = SettingsRepositoryImpl(
      SharedPreferencesSettingsLocalDataSource(widget.preferences),
    );
    _gameRecordRepository = GameRecordRepositoryImpl(
      SharedPreferencesGameRecordLocalDataSource(widget.preferences),
    );
    _ownedGameSoundPlayer = widget.gameSoundPlayer == null
        ? SynthesizedGameSoundPlayer()
        : null;
    _gameSoundPlayer = widget.gameSoundPlayer ?? _ownedGameSoundPlayer!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_gameSoundPlayer.prepare());
    });
  }

  @override
  void dispose() {
    final player = _ownedGameSoundPlayer;
    if (player != null) unawaited(player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(_settingsRepository),
        gameRecordRepositoryProvider.overrideWithValue(_gameRecordRepository),
        gameSoundPlayerProvider.overrideWithValue(_gameSoundPlayer),
      ],
      child: widget.child,
    );
  }
}
