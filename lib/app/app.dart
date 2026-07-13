import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xo_arena/app/notifiers/app_theme_notifier.dart';
import 'package:xo_arena/core/design_system/app_theme.dart';
import 'package:xo_arena/app/router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'XO Arena',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(appThemeProvider),
      routerConfig: appRouter,
    );
  }
}
