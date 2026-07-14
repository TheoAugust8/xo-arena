import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xo_arena/app/app.dart';
import 'package:xo_arena/app/di/app_provider_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(AppProviderScope(preferences: preferences, child: const App()));
}
