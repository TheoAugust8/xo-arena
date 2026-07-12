import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/app_spacing.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_rounded, size: 48),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Temporary screen',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.small),
              const Text('The board is coming in a dedicated step.'),
              const SizedBox(height: AppSpacing.large),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
