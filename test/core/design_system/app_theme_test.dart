import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/core/design_system/app_radius.dart';
import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';

void main() {
  test('reuses immutable light and dark theme instances', () {
    expect(identical(AppTheme.light, AppTheme.light), isTrue);
    expect(identical(AppTheme.dark, AppTheme.dark), isTrue);
  });

  test('exposes the 4 point spacing scale', () {
    expect(
      [
        AppSpacing.space4,
        AppSpacing.space8,
        AppSpacing.space12,
        AppSpacing.space16,
        AppSpacing.space20,
        AppSpacing.space24,
        AppSpacing.space32,
        AppSpacing.space40,
        AppSpacing.space48,
      ],
      [4, 8, 12, 16, 20, 24, 32, 40, 48],
    );
  });

  test('exposes the radius scale', () {
    expect(
      [
        AppRadius.none,
        AppRadius.xs,
        AppRadius.sm,
        AppRadius.md,
        AppRadius.lg,
        AppRadius.xl,
        AppRadius.full,
      ],
      [0, 4, 8, 12, 16, 20, 999],
    );
  });

  test('registers complete semantic tokens for dark and light modes', () {
    final dark = AppTheme.dark.extension<AppThemeTokens>()!;
    final light = AppTheme.light.extension<AppThemeTokens>()!;

    expect(dark.pageBackground, const Color(0xFF070709));
    expect(dark.background, const Color(0xFF0A0A0C));
    expect(dark.surface, const Color(0xFF141418));
    expect(dark.surface2, const Color(0xFF1C1C22));
    expect(dark.border, const Color(0x12FFFFFF));
    expect(dark.borderStrong, const Color(0x24FFFFFF));
    expect(dark.primary, const Color(0xFFD92B35));
    expect(dark.primaryDim, const Color(0x21D92B35));
    expect(dark.xCellBackground, const Color(0xFF160D0E));
    expect(dark.oCellBackground, const Color(0xFF141418));
    expect(dark.win, const Color(0xFF22C55E));
    expect(dark.winBackground, const Color(0xFF0B1A10));
    expect(dark.warn, const Color(0xFFF59E0B));
    expect(dark.draw, const Color(0xFF9090A0));
    expect(dark.cellPressedBackground, const Color(0xFF1A1A24));
    expect(dark.foreground, const Color(0xFFF0F0F4));
    expect(dark.foregroundSecondary, const Color(0xFFA0A0AC));
    expect(dark.mutedForeground, const Color(0xFF5E5E6A));
    expect(dark.oColor, const Color(0xFFD0D0DC));

    expect(light.pageBackground, const Color(0xFFE2E2E8));
    expect(light.background, const Color(0xFFF2F2F6));
    expect(light.surface, const Color(0xFFFFFFFF));
    expect(light.surface2, const Color(0xFFEAEAEF));
    expect(light.border, const Color(0x14000000));
    expect(light.borderStrong, const Color(0x29000000));
    expect(light.primary, const Color(0xFFD92B35));
    expect(light.xCellBackground, const Color(0xFFFFF1F1));
    expect(light.winBackground, const Color(0xFFEDFAF2));
    expect(light.foreground, const Color(0xFF0A0A0C));
    expect(light.oColor, const Color(0xFF1E1E2E));
    expect(light.draw, const Color(0xFF9090A0));
    expect(light.cellPressedBackground, const Color(0xFFEAEAEF));
  });

  test('maps Material 3 surface roles to semantic surfaces', () {
    final dark = AppTheme.dark.colorScheme;
    final light = AppTheme.light.colorScheme;

    expect(dark.surfaceContainer, AppThemeTokens.dark.surface2);
    expect(dark.surfaceContainerLowest, AppThemeTokens.dark.background);
    expect(dark.onSurfaceVariant, AppThemeTokens.dark.foregroundSecondary);
    expect(light.surfaceContainer, AppThemeTokens.light.surface2);
    expect(light.surfaceContainerLowest, AppThemeTokens.light.background);
    expect(light.onSurfaceVariant, AppThemeTokens.light.foregroundSecondary);
  });

  test('uses opaque semantic containers and a distinct error role', () {
    final colorScheme = AppTheme.dark.colorScheme;

    expect(colorScheme.primaryContainer.a, 1);
    expect(colorScheme.errorContainer.a, 1);
    expect(colorScheme.error, isNot(AppThemeTokens.dark.warn));
  });

  test('uses Barlow Condensed for display and Inter for UI copy', () {
    final dark = AppTheme.dark;
    final light = AppTheme.light;

    expect(dark.textTheme.displayLarge?.fontFamily, 'Barlow Condensed');
    expect(dark.textTheme.displayLarge?.fontWeight, FontWeight.w900);
    expect(dark.textTheme.displayLarge?.fontSize, 56);
    expect(dark.textTheme.headlineLarge?.fontFamily, 'Barlow Condensed');
    expect(dark.textTheme.headlineLarge?.fontSize, 30);
    expect(dark.textTheme.headlineMedium?.fontSize, 20);
    expect(dark.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(dark.textTheme.bodyMedium?.fontSize, 14);
    expect(dark.textTheme.labelLarge?.fontFamily, 'Inter');
    expect(dark.textTheme.labelMedium?.fontSize, 11);
    expect(dark.textTheme.bodySmall?.fontSize, 10);
    expect(light.textTheme.bodyMedium?.fontFamily, 'Inter');
  });

  test('interpolates every semantic token', () {
    final interpolated = AppThemeTokens.dark.lerp(AppThemeTokens.light, 0.5);

    expect(
      interpolated.background,
      Color.lerp(
        AppThemeTokens.dark.background,
        AppThemeTokens.light.background,
        0.5,
      ),
    );
    expect(
      interpolated.borderStrong,
      Color.lerp(
        AppThemeTokens.dark.borderStrong,
        AppThemeTokens.light.borderStrong,
        0.5,
      ),
    );
    expect(interpolated.panelShadow, hasLength(2));
  });
}
