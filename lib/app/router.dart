import 'package:go_router/go_router.dart';

import 'package:xo_arena/features/game/presentation/game_screen.dart';
import 'package:xo_arena/features/history/presentation/history_screen.dart';
import 'package:xo_arena/features/home/presentation/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/game', builder: (context, state) => const GameScreen()),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);
