import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/presentation/settings_ui.dart';

part 'settings_sheet_chrome.dart';
part 'settings_appearance_control.dart';
part 'settings_difficulty_control.dart';
part 'settings_skin_control.dart';

Future<void> showSettingsOverlay({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final disableAnimations = MediaQuery.disableAnimationsOf(context);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close settings',
    barrierColor: Colors.transparent,
    transitionDuration: disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, _, _) =>
        _SettingsOverlay(child: builder(dialogContext)),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class _SettingsOverlay extends StatelessWidget {
  const _SettingsOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final heightFactor =
        MediaQuery.sizeOf(context).height < 700 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.3
        ? 1.0
        : 0.75;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Semantics(
            button: true,
            label: 'Close settings',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 340),
                curve: Curves.easeOutCubic,
                builder: (context, value, panel) => Transform.translate(
                  offset: Offset(0, (1 - value) * 64),
                  child: panel,
                ),
                child: Material(
                  color: tokens.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    required this.settings,
    required this.onThemeChanged,
    required this.onDifficultyChanged,
    required this.onSkinChanged,
    required this.onSoundEnabledChanged,
    required this.onClose,
    super.key,
  });

  final AppSettings settings;
  final Future<void> Function(AppThemePreference value) onThemeChanged;
  final Future<void> Function(GameDifficulty value) onDifficultyChanged;
  final Future<void> Function(GameSymbolSkin value) onSkinChanged;
  final Future<void> Function(bool value) onSoundEnabledChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space24,
                AppSpacing.space12,
                AppSpacing.space24,
                AppSpacing.space12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _SheetHandle(),
                  const SizedBox(height: AppSpacing.space12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontFamily: 'Barlow Condensed',
                            fontSize: 22,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            color: context.appTokens.foreground,
                          ),
                        ),
                      ),
                      _SoundButton(
                        enabled: settings.soundEnabled,
                        onPressed: () => unawaited(
                          onSoundEnabledChanged(!settings.soundEnabled),
                        ),
                      ),
                      _CloseButton(onPressed: onClose),
                    ],
                  ),
                  const Divider(height: AppSpacing.space24),
                  const _SectionLabel('APPEARANCE'),
                  _ThemeToggle(
                    theme: settings.theme,
                    onThemeChanged: onThemeChanged,
                  ),
                  const Divider(height: AppSpacing.space24),
                  const _SectionLabel('DIFFICULTY'),
                  _DifficultyRail(
                    selected: settings.difficulty,
                    onChanged: onDifficultyChanged,
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  Text(
                    settings.difficulty.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.appTokens.mutedForeground,
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                  const Divider(height: AppSpacing.space24),
                  const _SectionLabel('SYMBOL SKIN'),
                  GridView.count(
                    padding: EdgeInsets.zero,
                    primary: false,
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.space12,
                    crossAxisSpacing: AppSpacing.space12,
                    childAspectRatio: 1.15,
                    children: GameSymbolSkin.values
                        .map(
                          (skin) => _SkinTile(
                            skin: skin,
                            selected: skin == settings.skin,
                            onPressed: () => unawaited(onSkinChanged(skin)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
