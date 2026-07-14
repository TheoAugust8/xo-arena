part of 'package:xo_arena/features/history/presentation/history_screen.dart';

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.stats});

  final GameRecordStats stats;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final summaryHeight = MediaQuery.textScalerOf(context).scale(1) > 1.25
        ? 84.0
        : 64.0;
    final values = [
      (stats.wins, 'W', tokens.win),
      (stats.draws, 'D', tokens.draw),
      (stats.losses, 'L', tokens.primary),
    ];
    return SizedBox(
      key: const ValueKey('history_summary'),
      height: summaryHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            for (var index = 0; index < values.length; index++) ...[
              Expanded(
                child: _SummaryValue(
                  value: values[index].$1,
                  label: values[index].$2,
                  color: values[index].$3,
                ),
              ),
              if (index < values.length - 1)
                VerticalDivider(width: 1, thickness: 1, color: tokens.border),
            ],
            SizedBox(
              width: 72,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.primary,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(15),
                  ),
                ),
                child: _SummaryValue(
                  value: '${stats.winRate}%',
                  label: 'WIN',
                  color: Colors.white,
                  labelColor: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.value,
    required this.label,
    required this.color,
    this.labelColor,
  });

  final Object value;
  final String label;
  final Color color;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$value',
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Barlow Condensed',
                color: color,
                fontSize: 24,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Inter',
                color: labelColor,
                fontSize: 9,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
