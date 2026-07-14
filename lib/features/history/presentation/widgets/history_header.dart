part of 'package:xo_arena/features/history/presentation/history_screen.dart';

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({
    required this.isMutating,
    required this.hasRecords,
    required this.onBack,
    required this.onClear,
  });

  final bool isMutating;
  final bool hasRecords;
  final VoidCallback onBack;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space20,
        AppSpacing.space12,
        AppSpacing.space12,
        AppSpacing.space12,
      ),
      child: largeText
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _BackButton(onPressed: onBack),
                    const Spacer(),
                    if (hasRecords)
                      _ClearButton(isMutating: isMutating, onPressed: onClear),
                  ],
                ),
                const SizedBox(height: AppSpacing.space12),
                const _HistoryTitle(),
              ],
            )
          : Row(
              children: [
                _BackButton(onPressed: onBack),
                const SizedBox(width: AppSpacing.space12),
                const Expanded(child: _HistoryTitle()),
                if (hasRecords)
                  _ClearButton(isMutating: isMutating, onPressed: onClear),
              ],
            ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Tooltip(
      message: 'Back to Home',
      child: SizedBox(
        width: 48,
        height: 48,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Ink(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tokens.surface,
                  border: Border.all(color: tokens.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: tokens.foregroundSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.isMutating, required this.onPressed});

  final bool isMutating;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppIconControl(
      key: const Key('clear-history'),
      tooltip: 'Clear match history',
      icon: Icons.delete_outline_rounded,
      onPressed: isMutating ? null : onPressed,
    );
  }
}

class _HistoryTitle extends StatelessWidget {
  const _HistoryTitle();

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'XO ARENA',
          style: TextStyle(
            color: tokens.primary,
            fontFamily: 'Inter',
            fontSize: 9,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Match History',
          style: TextStyle(
            color: tokens.foreground,
            fontFamily: 'Barlow Condensed',
            fontSize: 22,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
