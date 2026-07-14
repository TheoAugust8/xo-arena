import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/core/design_system/components/app_icon_control.dart';
import 'package:xo_arena/core/design_system/components/app_logo.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/settings/presentation/settings_overlay.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';
import 'package:xo_arena/shared/settings/presentation/settings_ui.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record_stats.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';

part 'widgets/home_content.dart';
part 'widgets/home_difficulty.dart';
part 'widgets/home_history_summary.dart';
part 'widgets/home_reveal.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(gameRecordsProvider);
    final difficulty = ref.watch(
      settingsProvider.select((settings) => settings.difficulty),
    );
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final usesScroll =
                constraints.maxHeight < 680 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.3;
            final content = _HomeContent(
              history: history,
              difficulty: difficulty,
              disableAnimations: disableAnimations,
              fillsAvailableHeight: !usesScroll,
              onSettings: () => showAppSettings(context),
              onDifficultyChanged: (value) => guardSettingsPersistence(
                context,
                ref.read(settingsProvider.notifier).setDifficulty(value),
              ),
              onPlay: () => context.go('/game'),
              onHistory: () => context.go('/history'),
              onRetryHistory: () => ref.invalidate(gameRecordsProvider),
            );

            if (usesScroll) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space20,
                  vertical: AppSpacing.space12,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: content,
                  ),
                ),
              );
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space20,
                    ),
                    child: content,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
