part of 'package:xo_arena/shared/settings/presentation/widgets/settings_sheet.dart';

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.theme, required this.onThemeChanged});

  final AppThemePreference theme;
  final Future<void> Function(AppThemePreference value) onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.themeSelected(_themeLabel(context, theme)),
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
                label: context.l10n.systemTheme,
                icon: Icons.phone_iphone_outlined,
                selected: theme == AppThemePreference.system,
                onPressed: () =>
                    unawaited(onThemeChanged(AppThemePreference.system)),
              ),
            ),
            Expanded(
              child: _ThemeOption(
                label: context.l10n.darkTheme,
                icon: Icons.nightlight_round,
                selected: theme == AppThemePreference.dark,
                onPressed: () =>
                    unawaited(onThemeChanged(AppThemePreference.dark)),
              ),
            ),
            Expanded(
              child: _ThemeOption(
                label: context.l10n.lightTheme,
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
      label: selected
          ? context.l10n.themeOptionSelected(label)
          : context.l10n.themeOption(label),
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

String _themeLabel(BuildContext context, AppThemePreference theme) {
  return switch (theme) {
    AppThemePreference.system => context.l10n.systemTheme,
    AppThemePreference.dark => context.l10n.darkTheme,
    AppThemePreference.light => context.l10n.lightTheme,
  };
}
