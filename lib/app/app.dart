import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xo_arena/app/router.dart';
import 'package:xo_arena/core/design_system/app_theme.dart';
import 'package:xo_arena/features/launch/presentation/startup_launch.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';
import 'package:xo_arena/shared/settings/presentation/settings_ui.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'XO Arena',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref
          .watch(settingsProvider.select((value) => value.theme))
          .materialThemeMode,
      routerConfig: appRouter,
      builder: (context, child) =>
          StartupLaunch(child: child ?? const SizedBox.shrink()),
    );
  }
}
