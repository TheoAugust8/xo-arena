import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_radius.dart';
import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';

abstract final class AppTheme {
  static final ThemeData light = _build(
    brightness: Brightness.light,
    tokens: AppThemeTokens.light,
  );

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    tokens: AppThemeTokens.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppThemeTokens tokens,
  }) {
    final colorScheme = _colorScheme(brightness, tokens);

    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Barlow Condensed',
        color: tokens.foreground,
        fontSize: 56,
        height: 1,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.4,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Barlow Condensed',
        color: tokens.foreground,
        fontSize: 50,
        height: 1,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Barlow Condensed',
        color: tokens.foreground,
        fontSize: 30,
        height: 1.1,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Barlow Condensed',
        color: tokens.foreground,
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        color: tokens.foreground,
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Inter',
        color: tokens.foregroundSecondary,
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        color: tokens.foreground,
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        color: tokens.foregroundSecondary,
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        color: tokens.foreground,
        fontSize: 13,
        height: 1,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        color: tokens.mutedForeground,
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Inter',
        color: tokens.mutedForeground,
        fontSize: 10,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    );

    return ThemeData.from(
      colorScheme: colorScheme,
      textTheme: textTheme,
      useMaterial3: true,
    ).copyWith(
      scaffoldBackgroundColor: tokens.background,
      extensions: [tokens],
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.background,
        foregroundColor: tokens.foreground,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: tokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: tokens.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.border,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.space24,
              vertical: AppSpacing.space16,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return tokens.surface2;
            }
            if (states.contains(WidgetState.pressed)) {
              return tokens.primary;
            }
            return tokens.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return tokens.mutedForeground;
            }
            return Colors.white;
          }),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.space24,
              vertical: AppSpacing.space16,
            ),
          ),
          foregroundColor: WidgetStatePropertyAll(tokens.foregroundSecondary),
          backgroundColor: WidgetStatePropertyAll(tokens.surface),
          side: WidgetStatePropertyAll(BorderSide(color: tokens.border)),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
            ),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? Colors.white
                : tokens.foregroundSecondary;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? tokens.primary
                : tokens.surface2;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: tokens.border)),
          textStyle: WidgetStatePropertyAll(textTheme.labelMedium),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
            ),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : tokens.mutedForeground;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? tokens.primary
              : tokens.surface2;
        }),
        trackOutlineColor: WidgetStatePropertyAll(tokens.border),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: tokens.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
    );
  }

  static ColorScheme _colorScheme(
    Brightness brightness,
    AppThemeTokens tokens,
  ) {
    final base = brightness == Brightness.dark
        ? const ColorScheme.dark()
        : const ColorScheme.light();

    return base.copyWith(
      primary: tokens.primary,
      onPrimary: Colors.white,
      primaryContainer: tokens.xCellBackground,
      onPrimaryContainer: tokens.foreground,
      secondary: tokens.oColor,
      onSecondary: tokens.background,
      secondaryContainer: tokens.surface2,
      onSecondaryContainer: tokens.foreground,
      tertiary: tokens.win,
      onTertiary: tokens.background,
      tertiaryContainer: tokens.winBackground,
      onTertiaryContainer: tokens.win,
      error: tokens.error,
      onError: Colors.white,
      errorContainer: tokens.errorBackground,
      onErrorContainer: tokens.foreground,
      surface: tokens.surface,
      onSurface: tokens.foreground,
      surfaceDim: tokens.pageBackground,
      surfaceBright: tokens.surface2,
      surfaceContainerLowest: tokens.background,
      surfaceContainerLow: tokens.surface,
      surfaceContainer: tokens.surface2,
      surfaceContainerHigh: tokens.surface2,
      surfaceContainerHighest: tokens.surface2,
      onSurfaceVariant: tokens.foregroundSecondary,
      outline: tokens.border,
      outlineVariant: tokens.borderStrong,
      inverseSurface: tokens.foreground,
      onInverseSurface: tokens.background,
      inversePrimary: tokens.primary,
      shadow: Colors.black,
      scrim: Colors.black,
      primaryFixed: tokens.primary,
      primaryFixedDim: tokens.primary,
      onPrimaryFixed: Colors.white,
      onPrimaryFixedVariant: Colors.white,
      secondaryFixed: tokens.oColor,
      secondaryFixedDim: tokens.oColor,
      onSecondaryFixed: tokens.background,
      onSecondaryFixedVariant: tokens.background,
      tertiaryFixed: tokens.win,
      tertiaryFixedDim: tokens.win,
      onTertiaryFixed: tokens.background,
      onTertiaryFixedVariant: tokens.background,
    );
  }
}
