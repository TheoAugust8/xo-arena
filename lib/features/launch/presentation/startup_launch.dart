import 'dart:async';

import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/core/design_system/components/app_logo.dart';

const launchDuration = Duration(milliseconds: 2900);
const launchExitDuration = Duration(milliseconds: 500);

class StartupLaunch extends StatefulWidget {
  const StartupLaunch({required this.child, super.key});

  final Widget child;

  @override
  State<StartupLaunch> createState() => _StartupLaunchState();
}

class _StartupLaunchState extends State<StartupLaunch> {
  Timer? _timer;
  var _completed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _timer?.cancel();
      _completed = true;
      return;
    }
    _timer ??= Timer(launchDuration, _complete);
  }

  void _complete() {
    if (!mounted) return;
    setState(() => _completed = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) return widget.child;

    return AnimatedSwitcher(
      duration: launchExitDuration,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: _completed
          ? KeyedSubtree(
              key: const ValueKey('app_content'),
              child: widget.child,
            )
          : const LaunchScreen(key: ValueKey('startup_launch')),
    );
  }
}

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: launchDuration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Semantics(
      label: 'XO Arena launch screen',
      container: true,
      excludeSemantics: true,
      child: ColoredBox(
        color: tokens.background,
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final progress = _controller.value;
                final arena = Curves.easeOut.transform(
                  _interval(progress, 0.41, 0.53),
                );
                final title = Curves.easeOutCubic.transform(
                  _interval(progress, 0.44, 0.60),
                );
                final tagline = Curves.easeOut.transform(
                  _interval(progress, 0.54, 0.68),
                );
                final bar = Curves.easeOut.transform(
                  _interval(progress, 0.50, 0.56),
                );
                final barFill = Curves.easeInOut.transform(
                  _interval(progress, 0.54, 0.94),
                );
                final glow = Curves.easeOut.transform(
                  _interval(progress, 0.31, 0.62),
                );

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 0.18 * glow,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [tokens.primary, Colors.transparent],
                                ),
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                          AppLogo(size: 120, drawProgress: progress),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Reveal(
                      progress: arena,
                      offset: 8,
                      child: Text(
                        'ARENA',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: tokens.primary,
                              fontSize: 9,
                              letterSpacing: 2.7,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _Reveal(
                      progress: title,
                      offset: 18,
                      child: Text(
                        'XO ARENA',
                        style: Theme.of(
                          context,
                        ).textTheme.displayMedium?.copyWith(fontSize: 42),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Reveal(
                      progress: tagline,
                      child: Text(
                        'Prove your edge against the machine.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: tokens.mutedForeground,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Opacity(
                      opacity: bar,
                      child: SizedBox(
                        width: 88,
                        height: 9,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: ColoredBox(
                                color: tokens.foreground.withValues(
                                  alpha: 0.12,
                                ),
                                child: SizedBox(
                                  key: const ValueKey('launch_loading_track'),
                                  width: 88,
                                  height: 3,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      key: const ValueKey(
                                        'launch_loading_fill',
                                      ),
                                      widthFactor: barFill,
                                      child: DecoratedBox(
                                        key: const ValueKey(
                                          'launch_loading_fill_paint',
                                        ),
                                        decoration: BoxDecoration(
                                          color: tokens.primary,
                                          borderRadius: BorderRadius.circular(
                                            99,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment(-1 + (2 * barFill), 0),
                              child: DecoratedBox(
                                key: const ValueKey('launch_loading_indicator'),
                                decoration: BoxDecoration(
                                  color: tokens.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: tokens.primary.withValues(
                                        alpha: 0.45,
                                      ),
                                      blurRadius: 7,
                                    ),
                                  ],
                                ),
                                child: const SizedBox.square(dimension: 7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({required this.progress, required this.child, this.offset = 0});

  final double progress;
  final double offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: progress,
      child: Transform.translate(
        offset: Offset(0, offset * (1 - progress)),
        child: child,
      ),
    );
  }
}

double _interval(double value, double begin, double end) {
  return ((value - begin) / (end - begin)).clamp(0, 1);
}
