part of 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';

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
