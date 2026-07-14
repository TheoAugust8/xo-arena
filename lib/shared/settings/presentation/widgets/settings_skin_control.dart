part of 'package:xo_arena/shared/settings/presentation/widgets/settings_sheet.dart';

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
