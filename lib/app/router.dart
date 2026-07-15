import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:xo_arena/core/constants/app_routes.dart';
import 'package:xo_arena/features/game/presentation/game_screen.dart';
import 'package:xo_arena/features/history/presentation/history_screen.dart';
import 'package:xo_arena/features/home/presentation/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (context, state) =>
          _page(state: state, child: const HomeScreen(), slide: false),
    ),
    GoRoute(
      path: AppRoutes.game,
      pageBuilder: (context, state) =>
          _page(state: state, child: const GameScreen()),
    ),
    GoRoute(
      path: AppRoutes.history,
      pageBuilder: (context, state) =>
          _page(state: state, child: const HistoryScreen()),
    ),
  ],
);

CustomTransitionPage<void> _page({
  required GoRouterState state,
  required Widget child,
  bool slide = true,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final faded = FadeTransition(opacity: curved, child: child);
      if (!slide) return faded;
      return SlideTransition(
        position: Tween(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(curved),
        child: faded,
      );
    },
  );
}
