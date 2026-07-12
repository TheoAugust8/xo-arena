import 'package:flutter/material.dart';

import '../core/design_system/app_theme.dart';
import 'router.dart';

class XoArenaApp extends StatelessWidget {
  const XoArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'XO Arena',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
