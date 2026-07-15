import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xo_arena/app/app.dart';
import 'package:xo_arena/app/di/app_provider_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  // AppProviderScope owns the root ProviderScope and dependency lifecycle.
  // ignore: riverpod_lint/missing_provider_scope
  runApp(AppProviderScope(preferences: preferences, child: const App()));
}
