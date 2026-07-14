part of 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';

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
