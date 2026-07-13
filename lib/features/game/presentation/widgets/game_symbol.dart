import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/features/game/presentation/models/game_symbol_skin.dart';

enum GameSymbolMark { x, o }

class GameSymbol extends StatelessWidget {
  const GameSymbol({
    required this.mark,
    this.skin = GameSymbolSkin.classic,
    this.size = 48,
    super.key,
  });

  final GameSymbolMark mark;
  final GameSymbolSkin skin;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final color = mark == GameSymbolMark.x ? tokens.primary : tokens.oColor;
    final symbol = mark == GameSymbolMark.x ? 'X' : 'O';

    return switch (skin) {
      GameSymbolSkin.classic => Text(
        symbol,
        style: TextStyle(
          fontFamily: 'Barlow Condensed',
          color: color,
          fontSize: size,
          height: 0.8,
          fontWeight: FontWeight.w900,
        ),
      ),
      GameSymbolSkin.geometric => CustomPaint(
        size: Size.square(size),
        painter: _GeometricSymbolPainter(mark: mark, color: color),
      ),
      GameSymbolSkin.power => Icon(
        mark == GameSymbolMark.x ? Icons.bolt : Icons.shield_outlined,
        color: color,
        size: size * 0.62,
        shadows: mark == GameSymbolMark.x
            ? [Shadow(color: color.withValues(alpha: 0.35), blurRadius: 8)]
            : null,
      ),
      GameSymbolSkin.nature => Icon(
        mark == GameSymbolMark.x
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
        color: color,
        size: size * 0.62,
      ),
    };
  }
}

class _GeometricSymbolPainter extends CustomPainter {
  const _GeometricSymbolPainter({required this.mark, required this.color});

  final GameSymbolMark mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = size.width * 0.18;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1375
      ..strokeCap = StrokeCap.round;

    if (mark == GameSymbolMark.x) {
      canvas
        ..drawLine(
          Offset(inset, inset),
          Offset(size.width - inset, size.height - inset),
          paint,
        )
        ..drawLine(
          Offset(size.width - inset, inset),
          Offset(inset, size.height - inset),
          paint,
        );
      return;
    }

    canvas.drawCircle(size.center(Offset.zero), size.width * 0.31, paint);
  }

  @override
  bool shouldRepaint(covariant _GeometricSymbolPainter oldDelegate) {
    return oldDelegate.mark != mark || oldDelegate.color != color;
  }
}
