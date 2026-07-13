import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:xo_arena/core/design_system/app_spacing.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('XO Arena')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.space16),
        children: [
          Text(
            'Foundations ready',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.space8),
          Text(
            'Start a game or review completed matches.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.space24),
          FilledButton.icon(
            onPressed: () => context.go('/game'),
            icon: const Icon(Icons.grid_view_rounded),
            label: const Text('Open Game'),
          ),
          const SizedBox(height: AppSpacing.space8),
          OutlinedButton.icon(
            onPressed: () => context.go('/history'),
            icon: const Icon(Icons.history_rounded),
            label: const Text('History'),
          ),
        ],
      ),
    );
  }
}
