part of 'package:xo_arena/shared/settings/presentation/widgets/settings_sheet.dart';

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
