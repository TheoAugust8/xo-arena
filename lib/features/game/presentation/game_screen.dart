import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/core/design_system/components/app_icon_control.dart';
import 'package:xo_arena/features/game/domain/entities/board.dart';
import 'package:xo_arena/features/game/domain/entities/game.dart';
import 'package:xo_arena/features/game/presentation/game_sound_effect.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_notifier.dart';
import 'package:xo_arena/features/game/presentation/notifiers/game_state.dart';
import 'package:xo_arena/features/game/presentation/providers/game_sound_provider.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_cell.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_score.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_status_badge.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';
import 'package:xo_arena/shared/settings/presentation/settings_overlay.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';

part 'widgets/game_layouts.dart';
part 'widgets/game_header.dart';
part 'widgets/game_controls.dart';
part 'widgets/game_board.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final state = ref.watch(gameProvider);
    final gameSettings = ref.watch(
      settingsProvider.select(
        (settings) => (settings.difficulty, settings.skin),
      ),
    );
    ref.listen<GameState>(gameProvider, (previous, next) {
      if (!ref.read(settingsProvider).soundEnabled) return;
      final cue = gameSoundCueForTransition(previous, next);
      if (cue != null) {
        unawaited(ref.read(gameSoundPlayerProvider).play(cue));
      }
    });
    ref.listen(gameProvider.select((value) => value.historySaveFailed), (
      previous,
      next,
    ) {
      if (next && previous != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Game completed, but history could not be saved.'),
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final header = _GameHeader(
                onBackPressed: () => context.go('/'),
                onSettingsPressed: () => showAppSettings(context),
              );
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              if (textScale > 1.3) {
                final contentWidth = constraints.maxWidth
                    .clamp(0, 360.0)
                    .toDouble();
                return SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: _PortraitGameContent(
                        header: header,
                        state: state,
                        difficulty: gameSettings.$1,
                        skin: gameSettings.$2,
                        notifier: notifier,
                        compact: false,
                      ),
                    ),
                  ),
                );
              }
              if (constraints.maxWidth > constraints.maxHeight) {
                return _LandscapeGameContent(
                  header: header,
                  state: state,
                  difficulty: gameSettings.$1,
                  skin: gameSettings.$2,
                  notifier: notifier,
                );
              }

              const regularPortraitMinHeight = 760.0;
              final compact = constraints.maxHeight < regularPortraitMinHeight;
              final nonBoardHeight = compact ? 376.0 : 380.0;
              final heightBoundWidth = constraints.maxHeight - nonBoardHeight;
              final contentWidth = heightBoundWidth
                  .clamp(144.0, constraints.maxWidth)
                  .clamp(0, 360.0)
                  .toDouble();
              return Center(
                child: SizedBox(
                  width: contentWidth,
                  child: _PortraitGameContent(
                    header: header,
                    state: state,
                    difficulty: gameSettings.$1,
                    skin: gameSettings.$2,
                    notifier: notifier,
                    compact: compact,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
