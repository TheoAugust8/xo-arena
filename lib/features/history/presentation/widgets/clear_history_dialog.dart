part of 'package:xo_arena/features/history/presentation/history_screen.dart';

class _ClearHistoryDialog extends StatelessWidget {
  const _ClearHistoryDialog();

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Dialog(
      backgroundColor: tokens.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: tokens.border),
      ),
      child: SizedBox(
        key: const ValueKey('clear_history_dialog'),
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                key: const ValueKey('clear_history_dialog_icon'),
                decoration: BoxDecoration(
                  color: tokens.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 52,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: tokens.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                context.l10n.clearHistoryTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: tokens.foreground,
                  fontFamily: AppFonts.display,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              Text(
                context.l10n.clearHistoryBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tokens.mutedForeground,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.space24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      key: const ValueKey('cancel_clear_history'),
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(context.l10n.cancel),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: SizedBox(
                      key: const ValueKey('confirm_clear_history'),
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: Text(context.l10n.clear),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
