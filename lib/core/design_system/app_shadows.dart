import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const panel = <BoxShadow>[
    BoxShadow(color: Color(0x73000000), blurRadius: 32, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x1FFFFFFF), blurRadius: 0, offset: Offset(0, 1)),
  ];
}
