import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';
import 'package:xo_arena/shared/settings/presentation/widgets/settings_sheet.dart';

Future<void> showAppSettings(BuildContext context) {
  return showSettingsOverlay(
    context: context,
    builder: (sheetContext) => Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(settingsProvider);
        final notifier = ref.read(settingsProvider.notifier);
        return SettingsSheet(
          settings: settings,
          onThemeChanged: (value) =>
              guardSettingsPersistence(sheetContext, notifier.setTheme(value)),
          onDifficultyChanged: (value) => guardSettingsPersistence(
            sheetContext,
            notifier.setDifficulty(value),
          ),
          onSkinChanged: (value) =>
              guardSettingsPersistence(sheetContext, notifier.setSkin(value)),
          onSoundEnabledChanged: (value) => guardSettingsPersistence(
            sheetContext,
            notifier.setSoundEnabled(value),
          ),
          onClose: () => Navigator.of(sheetContext).pop(),
        );
      },
    ),
  );
}

Future<void> guardSettingsPersistence(
  BuildContext context,
  Future<void> operation,
) async {
  try {
    await operation;
  } on Object {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unable to save settings.')));
  }
}
