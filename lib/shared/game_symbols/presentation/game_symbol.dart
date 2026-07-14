import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

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
      GameSymbolSkin.tennis => CustomPaint(
        size: Size.square(size),
        painter: _TennisSymbolPainter(mark: mark, color: color),
      ),
      GameSymbolSkin.football => CustomPaint(
        size: Size.square(size),
        painter: _FootballSymbolPainter(mark: mark, color: color),
      ),
      GameSymbolSkin.poker => CustomPaint(
        size: Size.square(size),
        painter: _PokerSymbolPainter(mark: mark, color: color),
      ),
      GameSymbolSkin.basketball => CustomPaint(
        size: Size.square(size),
        painter: _BasketballSymbolPainter(mark: mark, color: color),
      ),
    };
  }
}

class _TennisSymbolPainter extends CustomPainter {
  const _TennisSymbolPainter({required this.mark, required this.color});

  final GameSymbolMark mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.shortestSide;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.095
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (mark == GameSymbolMark.x) {
      _paintRacket(canvas, size, stroke);
      return;
    }

    _paintTennisBall(canvas, size);
  }

  void _paintRacket(Canvas canvas, Size size, Paint stroke) {
    final width = size.shortestSide;
    final center = size.center(Offset.zero);
    final strings = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, width * 0.03)
      ..strokeCap = StrokeCap.round;

    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(-math.pi / 4)
      ..translate(-center.dx, -center.dy);

    final head = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.35),
      width: width * 0.5,
      height: width * 0.54,
    );
    canvas
      ..drawOval(
        head,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.04),
            ],
          ).createShader(head)
          ..style = PaintingStyle.fill,
      )
      ..drawOval(head, stroke)
      ..drawLine(
        Offset(size.width * 0.5, size.height * 0.62),
        Offset(size.width * 0.5, size.height * 0.9),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width * 0.12
          ..strokeCap = StrokeCap.round,
      );

    canvas
      ..save()
      ..clipPath(Path()..addOval(head));
    for (final factor in const [0.42, 0.58]) {
      canvas.drawLine(
        Offset(size.width * factor, size.height * 0.08),
        Offset(size.width * factor, size.height * 0.62),
        strings,
      );
    }
    for (final factor in const [0.27, 0.43]) {
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * factor),
        Offset(size.width * 0.8, size.height * factor),
        strings,
      );
    }
    canvas
      ..restore()
      ..restore();
  }

  void _paintTennisBall(Canvas canvas, Size size) {
    final width = size.shortestSide;
    final center = size.center(Offset.zero);
    final radius = width * 0.37;
    canvas
      ..saveLayer(Offset.zero & size, Paint())
      ..drawCircle(
        center,
        radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );

    final seam = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.052
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.clear;
    final leftSeam = Path()
      ..moveTo(size.width * 0.29, size.height * 0.18)
      ..cubicTo(
        size.width * 0.57,
        size.height * 0.31,
        size.width * 0.57,
        size.height * 0.69,
        size.width * 0.29,
        size.height * 0.82,
      );
    final rightSeam = Path()
      ..moveTo(size.width * 0.71, size.height * 0.18)
      ..cubicTo(
        size.width * 0.43,
        size.height * 0.31,
        size.width * 0.43,
        size.height * 0.69,
        size.width * 0.71,
        size.height * 0.82,
      );
    canvas
      ..drawPath(leftSeam, seam)
      ..drawPath(rightSeam, seam)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _TennisSymbolPainter oldDelegate) {
    return oldDelegate.mark != mark || oldDelegate.color != color;
  }
}

class _FootballSymbolPainter extends CustomPainter {
  const _FootballSymbolPainter({required this.mark, required this.color});

  final GameSymbolMark mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.shortestSide;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.095
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (mark == GameSymbolMark.x) {
      _paintFootball(canvas, size);
      return;
    }

    _paintGoal(canvas, size, stroke);
  }

  void _paintFootball(Canvas canvas, Size size) {
    final width = size.shortestSide;
    final center = size.center(Offset.zero);
    final radius = width * 0.38;
    canvas
      ..saveLayer(Offset.zero & size, Paint())
      ..drawCircle(
        center,
        radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );

    final pentagon = Path();
    final innerPoints = <Offset>[];
    for (var index = 0; index < 5; index++) {
      final angle = -math.pi / 2 + (index * math.pi * 2 / 5);
      final point = Offset(
        center.dx + math.cos(angle) * width * 0.12,
        center.dy + math.sin(angle) * width * 0.12,
      );
      innerPoints.add(point);
      if (index == 0) {
        pentagon.moveTo(point.dx, point.dy);
      } else {
        pentagon.lineTo(point.dx, point.dy);
      }
    }
    pentagon.close();
    final cutout = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.clear;
    canvas.drawPath(pentagon, cutout);

    final seams = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, width * 0.036)
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.clear;
    for (var index = 0; index < innerPoints.length; index++) {
      final angle = -math.pi / 2 + (index * math.pi * 2 / 5);
      final direction = Offset(math.cos(angle), math.sin(angle));
      final outerPanelCenter = center + direction * radius * 0.72;
      canvas.drawPath(
        _regularPolygon(
          center: outerPanelCenter,
          radius: width * 0.062,
          sides: 5,
          rotation: angle,
        ),
        cutout,
      );
      canvas.drawLine(
        innerPoints[index],
        center + direction * radius * 0.6,
        seams,
      );
    }
    canvas.restore();
  }

  void _paintGoal(Canvas canvas, Size size, Paint stroke) {
    final frame = Path()
      ..moveTo(size.width * 0.14, size.height * 0.8)
      ..lineTo(size.width * 0.14, size.height * 0.22)
      ..lineTo(size.width * 0.72, size.height * 0.22)
      ..lineTo(size.width * 0.72, size.height * 0.8)
      ..lineTo(size.width * 0.88, size.height * 0.8)
      ..lineTo(size.width * 0.88, size.height * 0.38)
      ..lineTo(size.width * 0.72, size.height * 0.22);
    canvas.drawPath(frame, stroke);

    final net = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, size.shortestSide * 0.03)
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(
        Offset(size.width * 0.18, size.height * 0.35),
        Offset(size.width * 0.49, size.height * 0.76),
        net,
      )
      ..drawLine(
        Offset(size.width * 0.38, size.height * 0.27),
        Offset(size.width * 0.7, size.height * 0.76),
        net,
      )
      ..drawLine(
        Offset(size.width * 0.58, size.height * 0.27),
        Offset(size.width * 0.86, size.height * 0.67),
        net,
      )
      ..drawLine(
        Offset(size.width * 0.17, size.height * 0.5),
        Offset(size.width * 0.85, size.height * 0.5),
        net,
      )
      ..drawLine(
        Offset(size.width * 0.16, size.height * 0.67),
        Offset(size.width * 0.86, size.height * 0.67),
        net,
      );
  }

  @override
  bool shouldRepaint(covariant _FootballSymbolPainter oldDelegate) {
    return oldDelegate.mark != mark || oldDelegate.color != color;
  }
}

class _PokerSymbolPainter extends CustomPainter {
  const _PokerSymbolPainter({required this.mark, required this.color});

  final GameSymbolMark mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (mark == GameSymbolMark.x) {
      _paintAce(canvas, size);
      return;
    }

    _paintChip(canvas, size);
  }

  void _paintAce(Canvas canvas, Size size) {
    final width = size.shortestSide;
    final center = size.center(Offset.zero);
    final card = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        size.width * 0.18,
        size.height * 0.08,
        size.width * 0.82,
        size.height * 0.92,
      ),
      Radius.circular(width * 0.11),
    );
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.075
      ..strokeJoin = StrokeJoin.round;

    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(-math.pi / 30)
      ..translate(-center.dx, -center.dy)
      ..drawRRect(
        card,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.03),
            ],
          ).createShader(card.outerRect)
          ..style = PaintingStyle.fill,
      )
      ..drawRRect(card, stroke);

    final ace = TextPainter(
      text: TextSpan(
        text: 'A',
        style: TextStyle(
          color: color,
          fontFamily: 'Barlow Condensed',
          fontSize: width * 0.34,
          fontWeight: FontWeight.w900,
          height: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    ace.paint(canvas, Offset(size.width * 0.27, size.height * 0.18));
    canvas
      ..drawPath(_spadePath(size), Paint()..color = color)
      ..restore();
  }

  void _paintChip(Canvas canvas, Size size) {
    final width = size.shortestSide;
    final center = size.center(Offset.zero);
    final radius = width * 0.38;
    canvas
      ..saveLayer(Offset.zero & size, Paint())
      ..drawCircle(center, radius, Paint()..color = color);

    final cutout = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.052
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.clear;
    canvas.drawCircle(center, width * 0.21, cutout);

    final edgeCutout = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.09
      ..strokeCap = StrokeCap.square
      ..blendMode = BlendMode.clear;
    for (var index = 0; index < 8; index++) {
      final angle = index * math.pi / 4;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * width * 0.29,
        center + direction * width * 0.39,
        edgeCutout,
      );
    }
    canvas
      ..drawPath(
        _regularPolygon(
          center: center,
          radius: width * 0.075,
          sides: 4,
          rotation: math.pi / 4,
        ),
        Paint()
          ..color = Colors.transparent
          ..blendMode = BlendMode.clear,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _PokerSymbolPainter oldDelegate) {
    return oldDelegate.mark != mark || oldDelegate.color != color;
  }
}

class _BasketballSymbolPainter extends CustomPainter {
  const _BasketballSymbolPainter({required this.mark, required this.color});

  final GameSymbolMark mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (mark == GameSymbolMark.x) {
      _paintBall(canvas, size);
      return;
    }

    _paintHoop(canvas, size);
  }

  void _paintBall(Canvas canvas, Size size) {
    final width = size.shortestSide;
    final center = size.center(Offset.zero);
    final radius = width * 0.38;
    canvas
      ..saveLayer(Offset.zero & size, Paint())
      ..drawCircle(center, radius, Paint()..color = color);

    final seam = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.045
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.clear;
    canvas
      ..drawLine(
        Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius),
        seam,
      )
      ..drawLine(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        seam,
      )
      ..drawPath(
        Path()
          ..moveTo(size.width * 0.22, size.height * 0.24)
          ..cubicTo(
            size.width * 0.46,
            size.height * 0.34,
            size.width * 0.46,
            size.height * 0.66,
            size.width * 0.22,
            size.height * 0.76,
          ),
        seam,
      )
      ..drawPath(
        Path()
          ..moveTo(size.width * 0.78, size.height * 0.24)
          ..cubicTo(
            size.width * 0.54,
            size.height * 0.34,
            size.width * 0.54,
            size.height * 0.66,
            size.width * 0.78,
            size.height * 0.76,
          ),
        seam,
      )
      ..restore();
  }

  void _paintHoop(Canvas canvas, Size size) {
    final width = size.shortestSide;
    final frame = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final detail = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, width * 0.03)
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            size.width * 0.16,
            size.height * 0.1,
            size.width * 0.84,
            size.height * 0.46,
          ),
          Radius.circular(width * 0.045),
        ),
        frame,
      )
      ..drawRect(
        Rect.fromLTRB(
          size.width * 0.39,
          size.height * 0.25,
          size.width * 0.61,
          size.height * 0.46,
        ),
        detail,
      )
      ..drawOval(
        Rect.fromLTRB(
          size.width * 0.25,
          size.height * 0.43,
          size.width * 0.75,
          size.height * 0.59,
        ),
        frame,
      );

    final net = Path()
      ..moveTo(size.width * 0.29, size.height * 0.56)
      ..lineTo(size.width * 0.39, size.height * 0.88)
      ..lineTo(size.width * 0.61, size.height * 0.88)
      ..lineTo(size.width * 0.71, size.height * 0.56)
      ..moveTo(size.width * 0.39, size.height * 0.61)
      ..lineTo(size.width * 0.5, size.height * 0.88)
      ..lineTo(size.width * 0.61, size.height * 0.61)
      ..moveTo(size.width * 0.35, size.height * 0.73)
      ..lineTo(size.width * 0.65, size.height * 0.73);
    canvas.drawPath(net, detail);
  }

  @override
  bool shouldRepaint(covariant _BasketballSymbolPainter oldDelegate) {
    return oldDelegate.mark != mark || oldDelegate.color != color;
  }
}

Path _spadePath(Size size) {
  return Path()
    ..moveTo(size.width * 0.59, size.height * 0.35)
    ..cubicTo(
      size.width * 0.54,
      size.height * 0.44,
      size.width * 0.42,
      size.height * 0.5,
      size.width * 0.42,
      size.height * 0.61,
    )
    ..cubicTo(
      size.width * 0.42,
      size.height * 0.71,
      size.width * 0.53,
      size.height * 0.73,
      size.width * 0.59,
      size.height * 0.65,
    )
    ..lineTo(size.width * 0.55, size.height * 0.79)
    ..lineTo(size.width * 0.69, size.height * 0.79)
    ..lineTo(size.width * 0.65, size.height * 0.65)
    ..cubicTo(
      size.width * 0.71,
      size.height * 0.73,
      size.width * 0.82,
      size.height * 0.71,
      size.width * 0.82,
      size.height * 0.61,
    )
    ..cubicTo(
      size.width * 0.82,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.44,
      size.width * 0.59,
      size.height * 0.35,
    )
    ..close();
}

Path _regularPolygon({
  required Offset center,
  required double radius,
  required int sides,
  required double rotation,
}) {
  final path = Path();
  for (var index = 0; index < sides; index++) {
    final angle = rotation + (index * math.pi * 2 / sides);
    final point = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    if (index == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  return path..close();
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
