import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_radius.dart';
import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/features/game/domain/game_round.dart';
import 'package:xo_arena/features/game/presentation/models/game_difficulty_ui.dart';
import 'package:xo_arena/features/game/presentation/models/game_symbol_skin.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_symbol.dart';

class GameSettingsSheet extends StatelessWidget {
  const GameSettingsSheet({
    required this.themeMode,
    required this.difficulty,
    required this.skin,
    required this.onThemeModeChanged,
    required this.onDifficultyChanged,
    required this.onSkinChanged,
    super.key,
  });

  final ThemeMode themeMode;
  final GameDifficulty difficulty;
  final GameSymbolSkin skin;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<GameDifficulty> onDifficultyChanged;
  final ValueChanged<GameSymbolSkin> onSkinChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppSpacing.space24),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.space24),
        _SectionLabel(label: 'Theme'),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ButtonSegment(value: ThemeMode.light, label: Text('Light')),
          ],
          selected: {themeMode},
          onSelectionChanged: (selection) {
            onThemeModeChanged(selection.single);
          },
        ),
        const SizedBox(height: AppSpacing.space24),
        _SectionLabel(label: 'Difficulty'),
        SegmentedButton<GameDifficulty>(
          segments: GameDifficulty.values
              .map(
                (value) =>
                    ButtonSegment(value: value, label: Text(value.label)),
              )
              .toList(),
          selected: {difficulty},
          onSelectionChanged: (selection) {
            onDifficultyChanged(selection.single);
          },
        ),
        const SizedBox(height: AppSpacing.space8),
        Text(
          difficulty.description,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.space24),
        _SectionLabel(label: 'Skin'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.space12,
          crossAxisSpacing: AppSpacing.space12,
          childAspectRatio: 1.35,
          children: GameSymbolSkin.values
              .map(
                (value) => _SkinTile(
                  skin: value,
                  selected: value == skin,
                  onPressed: () => onSkinChanged(value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _SkinTile extends StatelessWidget {
  const _SkinTile({
    required this.skin,
    required this.selected,
    required this.onPressed,
  });

  final GameSymbolSkin skin;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return Material(
      color: selected
          ? tokens.primary.withValues(alpha: 0.12)
          : tokens.surface2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: selected ? tokens.primary : tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GameSymbol(mark: GameSymbolMark.x, skin: skin, size: 30),
                  const SizedBox(width: AppSpacing.space8),
                  GameSymbol(mark: GameSymbolMark.o, skin: skin, size: 30),
                ],
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(skin.label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
