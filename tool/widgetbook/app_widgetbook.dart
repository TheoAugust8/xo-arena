import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_radius.dart';
import 'package:xo_arena/core/design_system/app_theme.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_cell.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_score.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_status_badge.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/presentation/settings_ui.dart';
import 'package:xo_arena/shared/settings/presentation/widgets/settings_sheet.dart';

final List<WidgetbookNode> appWidgetbookDirectories = [
  WidgetbookFolder(
    name: 'Foundations',
    children: [
      WidgetbookComponent(
        name: 'Theme tokens',
        useCases: [
          WidgetbookUseCase(
            name: 'Dark',
            builder: (_) => _ThemePreview(
              theme: AppTheme.dark,
              child: const _TokenPreview(),
            ),
          ),
          WidgetbookUseCase(
            name: 'Light',
            builder: (_) => _ThemePreview(
              theme: AppTheme.light,
              child: const _TokenPreview(),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Typography',
        useCases: [
          WidgetbookUseCase(
            name: 'Scale',
            builder: (_) => const _TypographyPreview(),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Spacing',
        useCases: [
          WidgetbookUseCase(
            name: '4pt scale',
            builder: (_) => const _SpacingPreview(),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Radius',
        useCases: [
          WidgetbookUseCase(
            name: 'Scale',
            builder: (_) => const _RadiusPreview(),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Shadows',
        useCases: [
          WidgetbookUseCase(
            name: 'Panel',
            builder: (_) => const _ShadowPreview(),
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'Components',
    children: [
      WidgetbookComponent(
        name: 'Cells',
        useCases: GameCellVariant.values
            .map(
              (variant) => WidgetbookUseCase(
                name: _title(variant.name),
                builder: (_) => GameCell(variant: variant, onPressed: () {}),
              ),
            )
            .toList(),
      ),
      WidgetbookComponent(
        name: 'Status badges',
        useCases: GameStatusVariant.values
            .map(
              (variant) => WidgetbookUseCase(
                name: variant.label,
                builder: (_) => GameStatusBadge(variant: variant),
              ),
            )
            .toList(),
      ),
      WidgetbookComponent(
        name: 'Score',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (_) => const GameScore(
              playerScore: 3,
              cpuScore: 1,
              playerMark: GameSymbolMark.x,
              cpuMark: GameSymbolMark.o,
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Symbol skins',
        useCases: GameSymbolSkin.values
            .map(
              (skin) => WidgetbookUseCase(
                name: skin.label,
                builder: (_) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GameSymbol(mark: GameSymbolMark.x, skin: skin),
                    const SizedBox(width: AppSpacing.space16),
                    GameSymbol(mark: GameSymbolMark.o, skin: skin),
                  ],
                ),
              ),
            )
            .toList(),
      ),
      WidgetbookComponent(
        name: 'Settings',
        useCases: [
          _settingsUseCase(
            'Dark hard classic',
            AppThemePreference.dark,
            GameDifficulty.hard,
            GameSymbolSkin.classic,
          ),
          _settingsUseCase(
            'Light easy geometric',
            AppThemePreference.light,
            GameDifficulty.easy,
            GameSymbolSkin.geometric,
          ),
          _settingsUseCase(
            'Dark medium tennis',
            AppThemePreference.dark,
            GameDifficulty.medium,
            GameSymbolSkin.tennis,
          ),
          _settingsUseCase(
            'Light hard football',
            AppThemePreference.light,
            GameDifficulty.hard,
            GameSymbolSkin.football,
          ),
        ],
      ),
    ],
  ),
];

WidgetbookUseCase _settingsUseCase(
  String name,
  AppThemePreference theme,
  GameDifficulty difficulty,
  GameSymbolSkin skin,
) {
  return WidgetbookUseCase(
    name: name,
    builder: (_) => SizedBox(
      width: 420,
      child: SettingsSheet(
        settings: AppSettings(theme: theme, difficulty: difficulty, skin: skin),
        onThemeChanged: (_) async {},
        onDifficultyChanged: (_) async {},
        onSkinChanged: (_) async {},
        onSoundEnabledChanged: (_) async {},
        onClose: () {},
      ),
    ),
  );
}

class AppWidgetbook extends StatelessWidget {
  const AppWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: appWidgetbookDirectories,
      addons: [
        ViewportAddon(const [
          Viewports.none,
          IosViewports.iPhone13,
          AndroidViewports.samsungGalaxyS20,
        ]),
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'App dark', data: AppTheme.dark),
            WidgetbookTheme(name: 'App light', data: AppTheme.light),
          ],
        ),
        TextScaleAddon(),
        AlignmentAddon(),
      ],
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.theme, required this.child});

  final ThemeData theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => ColoredBox(
          color: context.appTokens.background,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _TokenPreview extends StatelessWidget {
  const _TokenPreview();

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;

    return SizedBox(
      width: 360,
      child: Card(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.space16),
          children: [
            Text(
              'Theme tokens',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.space16),
            _TokenRow(name: 'Page background', color: tokens.pageBackground),
            _TokenRow(name: 'Background', color: tokens.background),
            _TokenRow(name: 'Surface', color: tokens.surface),
            _TokenRow(name: 'Surface 2', color: tokens.surface2),
            _TokenRow(name: 'Border', color: tokens.border),
            _TokenRow(name: 'Border strong', color: tokens.borderStrong),
            _TokenRow(name: 'Primary', color: tokens.primary),
            _TokenRow(name: 'Primary dim', color: tokens.primaryDim),
            _TokenRow(name: 'X cell background', color: tokens.xCellBackground),
            _TokenRow(name: 'O cell background', color: tokens.oCellBackground),
            _TokenRow(name: 'Win', color: tokens.win),
            _TokenRow(name: 'Win background', color: tokens.winBackground),
            _TokenRow(name: 'Warn', color: tokens.warn),
            _TokenRow(name: 'Draw', color: tokens.draw),
            _TokenRow(
              name: 'Cell pressed background',
              color: tokens.cellPressedBackground,
            ),
            _TokenRow(name: 'Foreground', color: tokens.foreground),
            _TokenRow(
              name: 'Foreground secondary',
              color: tokens.foregroundSecondary,
            ),
            _TokenRow(name: 'Muted foreground', color: tokens.mutedForeground),
            _TokenRow(name: 'O symbol', color: tokens.oColor),
          ],
        ),
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  const _TokenRow({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space12),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: const SizedBox.square(dimension: 32),
          ),
          const SizedBox(width: AppSpacing.space12),
          Expanded(
            child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _TypographyPreview extends StatelessWidget {
  const _TypographyPreview();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _FoundationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('0 3 9', style: textTheme.displayLarge),
          Text('XO ARENA', style: textTheme.headlineLarge),
          Text('Match', style: textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.space8),
          Text('Tap a cell to make your move.', style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.space8),
          Text('YOUR TURN', style: textTheme.labelMedium),
          Text('--primary · 4pt · radius-md', style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SpacingPreview extends StatelessWidget {
  const _SpacingPreview();

  @override
  Widget build(BuildContext context) {
    const values = [4.0, 8.0, 12.0, 16.0, 20.0, 24.0, 32.0, 40.0, 48.0];
    final tokens = context.appTokens;
    return _FoundationCard(
      child: Wrap(
        spacing: AppSpacing.space12,
        runSpacing: AppSpacing.space12,
        children: values
            .map(
              (value) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: value,
                    child: ColoredBox(color: tokens.primary),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    '${value.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _RadiusPreview extends StatelessWidget {
  const _RadiusPreview();

  @override
  Widget build(BuildContext context) {
    const values = [
      AppRadius.none,
      AppRadius.xs,
      AppRadius.sm,
      AppRadius.md,
      AppRadius.lg,
      AppRadius.xl,
      AppRadius.full,
    ];
    final tokens = context.appTokens;
    return _FoundationCard(
      child: Wrap(
        spacing: AppSpacing.space12,
        runSpacing: AppSpacing.space12,
        children: values
            .map(
              (value) => DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.surface2,
                  border: Border.all(color: tokens.borderStrong),
                  borderRadius: BorderRadius.circular(value),
                ),
                child: const SizedBox.square(dimension: 48),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ShadowPreview extends StatelessWidget {
  const _ShadowPreview();

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return _FoundationCard(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: tokens.panelShadow,
        ),
        child: const SizedBox(width: 240, height: 120),
      ),
    );
  }
}

class _FoundationCard extends StatelessWidget {
  const _FoundationCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: child,
        ),
      ),
    );
  }
}

String _title(String value) {
  return '${value[0].toUpperCase()}${value.substring(1)}';
}
