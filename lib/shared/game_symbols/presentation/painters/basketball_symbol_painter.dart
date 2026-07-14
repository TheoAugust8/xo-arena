part of 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';

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
