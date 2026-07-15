part of 'package:xo_arena/features/game/presentation/game_screen.dart';

class _GameHeader extends StatelessWidget {
  const _GameHeader({
    required this.onBackPressed,
    required this.onSettingsPressed,
  });

  final VoidCallback onBackPressed;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Row(
      children: [
        AppIconControl(
          key: const ValueKey('game_back_button'),
          tooltip: context.l10n.backToHome,
          icon: Icons.chevron_left,
          visualSize: 36,
          iconSize: 20,
          onPressed: onBackPressed,
        ),
        const SizedBox(width: AppSpacing.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.brandArena,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  color: tokens.primary,
                  fontSize: 9,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                context.l10n.brandName,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  color: tokens.foreground,
                  fontSize: 24,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        AppIconControl(
          key: const ValueKey('game_settings_button'),
          tooltip: context.l10n.settings,
          icon: Icons.settings_outlined,
          visualSize: 40,
          iconSize: 18,
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }
}
