import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';

part 'painters/basketball_symbol_painter.dart';
part 'painters/football_symbol_painter.dart';
part 'painters/geometric_symbol_painter.dart';
part 'painters/poker_symbol_painter.dart';
part 'painters/symbol_painter_utils.dart';
part 'painters/tennis_symbol_painter.dart';

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
