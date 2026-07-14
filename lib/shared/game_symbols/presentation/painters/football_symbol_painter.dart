part of 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';

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
