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
    final backButton = AppIconControl(
      tooltip: context.l10n.backToHome,
      icon: Icons.chevron_left,
      visualSize: 36,
      onPressed: onBack,
    );
    final clearButton = hasRecords
        ? AppIconControl(
            key: const Key('clear-history'),
            tooltip: context.l10n.clearMatchHistory,
            icon: Icons.delete_outline_rounded,
            onPressed: isMutating ? null : onClear,
          )
        : null;
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
                Row(children: [backButton, const Spacer(), ?clearButton]),
                const SizedBox(height: AppSpacing.space12),
                const _HistoryTitle(),
              ],
            )
          : Row(
              children: [
                backButton,
                const SizedBox(width: AppSpacing.space12),
                const Expanded(child: _HistoryTitle()),
                ?clearButton,
              ],
            ),
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
          context.l10n.brandName,
          style: TextStyle(
            color: tokens.primary,
            fontFamily: AppFonts.body,
            fontSize: 9,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          context.l10n.matchHistory,
          style: TextStyle(
            color: tokens.foreground,
            fontFamily: AppFonts.display,
            fontSize: 22,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
