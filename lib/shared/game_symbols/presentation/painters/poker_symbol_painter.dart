part of 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';

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
          fontFamily: AppFonts.display,
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
