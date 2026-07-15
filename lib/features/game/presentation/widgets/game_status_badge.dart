import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_radius.dart';
import 'package:xo_arena/core/design_system/app_spacing.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/l10n/l10n.dart';

enum GameStatusVariant { player, cpu, playerWin, cpuWin, draw }

extension GameStatusVariantLabel on GameStatusVariant {
  String label(AppLocalizations l10n) => switch (this) {
    GameStatusVariant.player => l10n.yourTurn,
    GameStatusVariant.cpu => l10n.cpuThinking,
    GameStatusVariant.playerWin => l10n.youWin,
    GameStatusVariant.cpuWin => l10n.cpuWins,
    GameStatusVariant.draw => l10n.draw,
  };
}

class GameStatusBadge extends StatelessWidget {
  const GameStatusBadge({required this.variant, super.key});

  final GameStatusVariant variant;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final color = switch (variant) {
      GameStatusVariant.player => tokens.win,
      GameStatusVariant.cpu => tokens.warn,
      GameStatusVariant.playerWin => tokens.win,
      GameStatusVariant.cpuWin => tokens.primary,
      GameStatusVariant.draw => tokens.draw,
    };
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);
    final label = variant.label(context.l10n);

    return Semantics(
      liveRegion: true,
      label: label,
      excludeSemantics: true,
      child: AnimatedSwitcher(
        duration: duration,
        reverseDuration: duration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offset = Tween<Offset>(
            begin: const Offset(0, -0.35),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offset,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: DecoratedBox(
          key: ValueKey('game_status_${variant.name}'),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GameActivityDot(
                  color: color,
                  isPulsing:
                      variant == GameStatusVariant.player ||
                      variant == GameStatusVariant.cpu,
                ),
                const SizedBox(width: AppSpacing.space8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
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

class GameActivityDot extends StatefulWidget {
  const GameActivityDot({
    required this.color,
    required this.isPulsing,
    this.size = AppSpacing.space8,
    super.key,
  });

  final Color color;
  final bool isPulsing;
  final double size;

  @override
  State<GameActivityDot> createState() => _GameActivityDotState();
}

class _GameActivityDotState extends State<GameActivityDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void didUpdateWidget(covariant GameActivityDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPulsing != widget.isPulsing) _syncAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.isPulsing && !MediaQuery.disableAnimationsOf(context)) {
      _controller.repeat(reverse: true);
      return;
    }
    _controller
      ..stop()
      ..value = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = widget.isPulsing ? _controller.value : 0.0;
        return Opacity(
          opacity: 1 - (pulse * 0.8),
          child: Transform.scale(scale: 1 - (pulse * 0.2), child: child),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
        child: SizedBox.square(dimension: widget.size),
      ),
    );
  }
}
