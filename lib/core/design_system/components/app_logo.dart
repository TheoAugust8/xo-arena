import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_theme_tokens.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 72, this.drawProgress = 1, super.key});

  final double size;
  final double drawProgress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'XO Arena logo',
      image: true,
      child: ExcludeSemantics(
        child: CustomPaint(
          size: Size.square(size),
          painter: _XoArenaLogoPainter(
            background: isDark ? const Color(0xFF10101A) : Colors.white,
            border: tokens.primary,
            xColor: tokens.primary,
            oColor: tokens.oColor,
            detail: isDark ? const Color(0x12FFFFFF) : const Color(0x12000000),
            drawProgress: drawProgress.clamp(0, 1),
          ),
        ),
      ),
    );
  }
}

class _XoArenaLogoPainter extends CustomPainter {
  const _XoArenaLogoPainter({
    required this.background,
    required this.border,
    required this.xColor,
    required this.oColor,
    required this.detail,
    required this.drawProgress,
  });

  final Color background;
  final Color border;
  final Color xColor;
  final Color oColor;
  final Color detail;
  final double drawProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 64;
    final badgeProgress = Curves.easeOutBack.transform(
      _interval(drawProgress, 0.03, 0.31),
    );
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1.5 * unit, 1.5 * unit, 61 * unit, 61 * unit),
      Radius.circular(15 * unit),
    );
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(badgeProgress, badgeProgress);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawRRect(badgeRect, Paint()..color = background);
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.75 * unit,
    );
    canvas.restore();

    _drawPartialLine(
      canvas,
      start: Offset(32 * unit, 12 * unit),
      end: Offset(32 * unit, 52 * unit),
      progress: _interval(drawProgress, 0.16, 0.24),
      paint: Paint()
        ..color = detail
        ..strokeWidth = 0.75 * unit,
    );
    final xPaint = Paint()
      ..color = xColor
      ..strokeWidth = 6 * unit
      ..strokeCap = StrokeCap.round;
    _drawPartialLine(
      canvas,
      start: Offset(11 * unit, 20 * unit),
      end: Offset(27 * unit, 44 * unit),
      progress: Curves.easeOut.transform(_interval(drawProgress, 0.20, 0.31)),
      paint: xPaint,
    );
    _drawPartialLine(
      canvas,
      start: Offset(27 * unit, 20 * unit),
      end: Offset(11 * unit, 44 * unit),
      progress: Curves.easeOut.transform(_interval(drawProgress, 0.27, 0.38)),
      paint: xPaint,
    );
    final oProgress = Curves.easeInOut.transform(
      _interval(drawProgress, 0.34, 0.52),
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(45 * unit, 32 * unit),
        radius: 11.5 * unit,
      ),
      -math.pi / 2,
      math.pi * 2 * oProgress,
      false,
      Paint()
        ..color = oColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5 * unit,
    );
  }

  static double _interval(double value, double begin, double end) {
    return ((value - begin) / (end - begin)).clamp(0, 1);
  }

  static void _drawPartialLine(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required double progress,
    required Paint paint,
  }) {
    if (progress == 0) return;
    canvas.drawLine(start, Offset.lerp(start, end, progress)!, paint);
  }

  @override
  bool shouldRepaint(covariant _XoArenaLogoPainter oldDelegate) {
    return oldDelegate.background != background ||
        oldDelegate.border != border ||
        oldDelegate.xColor != xColor ||
        oldDelegate.oColor != oColor ||
        oldDelegate.detail != detail ||
        oldDelegate.drawProgress != drawProgress;
  }
}
