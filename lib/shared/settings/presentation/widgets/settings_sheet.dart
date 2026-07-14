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
    required this.theme,
    required this.settings,
    required this.onThemeChanged,
    required this.onDifficultyChanged,
    required this.onSkinChanged,
    required this.onSoundEnabledChanged,
    required this.onClose,
    super.key,
  });

  final AppThemePreference theme;
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
                  _AppearanceControl(
                    theme: theme,
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

class _SoundButton extends StatelessWidget {
  const _SoundButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final label = enabled ? 'Turn sound off' : 'Turn sound on';
    return Tooltip(
      message: label,
      child: Semantics(
        key: const ValueKey('settings_sound_toggle'),
        button: true,
        toggled: enabled,
        label: label,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Center(
                child: Ink(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: enabled ? tokens.primaryDim : tokens.surface2,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    enabled
                        ? Icons.volume_up_outlined
                        : Icons.volume_off_outlined,
                    size: 16,
                    color: enabled
                        ? tokens.primary
                        : tokens.foregroundSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.appTokens.borderStrong,
          borderRadius: BorderRadius.circular(99),
        ),
        child: const SizedBox(width: 40, height: 5),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close settings',
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: Material(
              color: context.appTokens.surface2,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: context.appTokens.foregroundSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.space12),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: context.appTokens.mutedForeground,
            fontSize: 9,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
      ),
    );
  }
}

class _AppearanceControl extends StatelessWidget {
  const _AppearanceControl({required this.theme, required this.onThemeChanged});

  final AppThemePreference theme;
  final Future<void> Function(AppThemePreference value) onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return _ThemeToggle(theme: theme, onThemeChanged: onThemeChanged);
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.theme, required this.onThemeChanged});

  final AppThemePreference theme;
  final Future<void> Function(AppThemePreference value) onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Theme, ${theme.name} selected',
      child: Container(
        key: const ValueKey('settings_theme_toggle'),
        height: 48,
        width: double.infinity,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: context.appTokens.surface2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ThemeOption(
                label: 'System',
                icon: Icons.phone_iphone_outlined,
                selected: theme == AppThemePreference.system,
                onPressed: () =>
                    unawaited(onThemeChanged(AppThemePreference.system)),
              ),
            ),
            Expanded(
              child: _ThemeOption(
                label: 'Dark',
                icon: Icons.nightlight_round,
                selected: theme == AppThemePreference.dark,
                onPressed: () =>
                    unawaited(onThemeChanged(AppThemePreference.dark)),
              ),
            ),
            Expanded(
              child: _ThemeOption(
                label: 'Light',
                icon: Icons.light_mode_outlined,
                selected: theme == AppThemePreference.light,
                onPressed: () =>
                    unawaited(onThemeChanged(AppThemePreference.light)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
    return Semantics(
      key: ValueKey('settings_theme_${label.toLowerCase()}'),
      button: true,
      selected: selected,
      label: '$label theme${selected ? ', selected' : ''}',
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? tokens.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.white : tokens.foregroundSecondary,
                ),
                const SizedBox(width: AppSpacing.space8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected
                            ? Colors.white
                            : tokens.foregroundSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyRail extends StatelessWidget {
  const _DifficultyRail({required this.selected, required this.onChanged});

  final GameDifficulty selected;
  final Future<void> Function(GameDifficulty value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('settings_difficulty_rail'),
      height: 48,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: context.appTokens.surface2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: GameDifficulty.values
            .map(
              (value) => Expanded(
                child: _DifficultyOption(
                  value: value,
                  selected: value == selected,
                  onPressed: () => unawaited(onChanged(value)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  const _DifficultyOption({
    required this.value,
    required this.selected,
    required this.onPressed,
  });

  final GameDifficulty value;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
    return Semantics(
      key: ValueKey('settings_difficulty_${value.name}'),
      button: true,
      selected: selected,
      label: '${value.label} difficulty${selected ? ', selected' : ''}',
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? tokens.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value.label,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? Colors.white : tokens.foregroundSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
    return Semantics(
      button: true,
      selected: selected,
      label: '${skin.label} symbol skin${selected ? ', selected' : ''}',
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: AnimatedContainer(
            key: ValueKey('settings_skin_${skin.name}'),
            duration: duration,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: selected ? tokens.primaryDim : tokens.surface2,
              border: Border.all(
                color: selected ? tokens.primary : Colors.transparent,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SkinPreview(skin: skin),
                const SizedBox(height: AppSpacing.space12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space8,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      skin.label,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected
                            ? tokens.primary
                            : tokens.foregroundSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkinPreview extends StatelessWidget {
  const _SkinPreview({required this.skin});

  final GameSymbolSkin skin;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SkinMark(mark: GameSymbolMark.x, skin: skin),
          const SizedBox(width: AppSpacing.space8),
          _SkinMark(mark: GameSymbolMark.o, skin: skin),
        ],
      ),
    );
  }
}

class _SkinMark extends StatelessWidget {
  const _SkinMark({required this.mark, required this.skin});

  final GameSymbolMark mark;
  final GameSymbolSkin skin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.appTokens.background,
        border: Border.all(color: context.appTokens.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GameSymbol(mark: mark, skin: skin, size: 30),
    );
  }
}
