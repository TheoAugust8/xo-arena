part of 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';

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
