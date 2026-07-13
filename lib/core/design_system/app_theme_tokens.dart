import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_shadows.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.pageBackground,
    required this.background,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.borderStrong,
    required this.primary,
    required this.primaryDim,
    required this.xCellBackground,
    required this.oCellBackground,
    required this.win,
    required this.winBackground,
    required this.warn,
    required this.error,
    required this.errorBackground,
    required this.draw,
    required this.cellPressedBackground,
    required this.foreground,
    required this.foregroundSecondary,
    required this.mutedForeground,
    required this.oColor,
    required this.panelShadow,
  });

  static const dark = AppThemeTokens(
    pageBackground: Color(0xFF070709),
    background: Color(0xFF0A0A0C),
    surface: Color(0xFF141418),
    surface2: Color(0xFF1C1C22),
    border: Color(0x12FFFFFF),
    borderStrong: Color(0x24FFFFFF),
    primary: Color(0xFFD92B35),
    primaryDim: Color(0x21D92B35),
    xCellBackground: Color(0xFF160D0E),
    oCellBackground: Color(0xFF141418),
    win: Color(0xFF22C55E),
    winBackground: Color(0xFF0B1A10),
    warn: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    errorBackground: Color(0xFF240D10),
    draw: Color(0xFF9090A0),
    cellPressedBackground: Color(0xFF1A1A24),
    foreground: Color(0xFFF0F0F4),
    foregroundSecondary: Color(0xFFA0A0AC),
    mutedForeground: Color(0xFF5E5E6A),
    oColor: Color(0xFFD0D0DC),
    panelShadow: AppShadows.panel,
  );

  static const light = AppThemeTokens(
    pageBackground: Color(0xFFE2E2E8),
    background: Color(0xFFF2F2F6),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFEAEAEF),
    border: Color(0x14000000),
    borderStrong: Color(0x29000000),
    primary: Color(0xFFD92B35),
    primaryDim: Color(0x17D92B35),
    xCellBackground: Color(0xFFFFF1F1),
    oCellBackground: Color(0xFFFFFFFF),
    win: Color(0xFF16A34A),
    winBackground: Color(0xFFEDFAF2),
    warn: Color(0xFFC47A08),
    error: Color(0xFFB91C1C),
    errorBackground: Color(0xFFFEECEC),
    draw: Color(0xFF9090A0),
    cellPressedBackground: Color(0xFFEAEAEF),
    foreground: Color(0xFF0A0A0C),
    foregroundSecondary: Color(0xFF46465A),
    mutedForeground: Color(0xFF8E8EA0),
    oColor: Color(0xFF1E1E2E),
    panelShadow: <BoxShadow>[
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
      BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
    ],
  );

  final Color pageBackground;
  final Color background;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color borderStrong;
  final Color primary;
  final Color primaryDim;
  final Color xCellBackground;
  final Color oCellBackground;
  final Color win;
  final Color winBackground;
  final Color warn;
  final Color error;
  final Color errorBackground;
  final Color draw;
  final Color cellPressedBackground;
  final Color foreground;
  final Color foregroundSecondary;
  final Color mutedForeground;
  final Color oColor;
  final List<BoxShadow> panelShadow;

  @override
  AppThemeTokens copyWith({
    Color? pageBackground,
    Color? background,
    Color? surface,
    Color? surface2,
    Color? border,
    Color? borderStrong,
    Color? primary,
    Color? primaryDim,
    Color? xCellBackground,
    Color? oCellBackground,
    Color? win,
    Color? winBackground,
    Color? warn,
    Color? error,
    Color? errorBackground,
    Color? draw,
    Color? cellPressedBackground,
    Color? foreground,
    Color? foregroundSecondary,
    Color? mutedForeground,
    Color? oColor,
    List<BoxShadow>? panelShadow,
  }) {
    return AppThemeTokens(
      pageBackground: pageBackground ?? this.pageBackground,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      primary: primary ?? this.primary,
      primaryDim: primaryDim ?? this.primaryDim,
      xCellBackground: xCellBackground ?? this.xCellBackground,
      oCellBackground: oCellBackground ?? this.oCellBackground,
      win: win ?? this.win,
      winBackground: winBackground ?? this.winBackground,
      warn: warn ?? this.warn,
      error: error ?? this.error,
      errorBackground: errorBackground ?? this.errorBackground,
      draw: draw ?? this.draw,
      cellPressedBackground:
          cellPressedBackground ?? this.cellPressedBackground,
      foreground: foreground ?? this.foreground,
      foregroundSecondary: foregroundSecondary ?? this.foregroundSecondary,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      oColor: oColor ?? this.oColor,
      panelShadow: panelShadow ?? this.panelShadow,
    );
  }

  @override
  AppThemeTokens lerp(
    covariant ThemeExtension<AppThemeTokens>? other,
    double t,
  ) {
    if (other is! AppThemeTokens) {
      return this;
    }

    return AppThemeTokens(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDim: Color.lerp(primaryDim, other.primaryDim, t)!,
      xCellBackground: Color.lerp(xCellBackground, other.xCellBackground, t)!,
      oCellBackground: Color.lerp(oCellBackground, other.oCellBackground, t)!,
      win: Color.lerp(win, other.win, t)!,
      winBackground: Color.lerp(winBackground, other.winBackground, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      draw: Color.lerp(draw, other.draw, t)!,
      cellPressedBackground: Color.lerp(
        cellPressedBackground,
        other.cellPressedBackground,
        t,
      )!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      foregroundSecondary: Color.lerp(
        foregroundSecondary,
        other.foregroundSecondary,
        t,
      )!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      oColor: Color.lerp(oColor, other.oColor, t)!,
      panelShadow:
          BoxShadow.lerpList(panelShadow, other.panelShadow, t) ?? panelShadow,
    );
  }
}

extension AppThemeTokensContext on BuildContext {
  AppThemeTokens get appTokens =>
      Theme.of(this).extension<AppThemeTokens>() ??
      (throw StateError('AppThemeTokens missing from ThemeData.extensions.'));
}
