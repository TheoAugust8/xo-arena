part of 'package:xo_arena/features/home/presentation/home_screen.dart';

class _Reveal extends StatelessWidget {
  const _Reveal({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: enabled ? 0 : 1, end: 1),
      duration: enabled ? const Duration(milliseconds: 400) : Duration.zero,
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0, 1),
        child: Transform.scale(scale: 0.82 + value * 0.18, child: child),
      ),
      child: child,
    );
  }
}
