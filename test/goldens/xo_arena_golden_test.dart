import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/features/game/domain/services/game_sound_player.dart';
import 'package:xo_arena/features/game/presentation/game_screen.dart';
import 'package:xo_arena/features/game/presentation/providers/game_sound_provider.dart';
import 'package:xo_arena/features/history/presentation/history_screen.dart';
import 'package:xo_arena/features/home/presentation/home_screen.dart';
import 'package:xo_arena/shared/game_configuration/domain/entities/game_difficulty.dart';
import 'package:xo_arena/shared/game_records/domain/entities/game_record.dart';
import 'package:xo_arena/shared/game_records/domain/repositories/game_record_repository.dart';
import 'package:xo_arena/shared/game_records/presentation/game_record_providers.dart';
import 'package:xo_arena/shared/game_symbols/domain/entities/game_symbol_skin.dart';
import 'package:xo_arena/shared/game_symbols/presentation/game_symbol.dart';
import 'package:xo_arena/shared/settings/domain/entities/app_settings.dart';
import 'package:xo_arena/shared/settings/domain/repositories/settings_repository.dart';
import 'package:xo_arena/shared/settings/presentation/settings_providers.dart';
import 'package:xo_arena/shared/settings/presentation/widgets/settings_sheet.dart';

import 'golden_test_support.dart';

void main() {
  setUpAll(loadGoldenFonts);
  setUp(configureGoldenComparator);

  testWidgets('matches Home with session statistics', (tester) async {
    final records = [
      _record(id: 'win', outcome: GameOutcome.playerOneWin),
      _record(id: 'draw', outcome: GameOutcome.draw),
      _record(id: 'loss', outcome: GameOutcome.playerTwoWin),
    ];

    await pumpGolden(
      tester,
      ProviderScope(
        overrides: [
          gameRecordsProvider.overrideWith((ref) async => records),
          settingsRepositoryProvider.overrideWithValue(
            _MemorySettingsRepository(),
          ),
        ],
        child: goldenApp(home: const HomeScreen()),
      ),
    );

    await expectLater(
      find.byKey(goldenSurfaceKey),
      matchesGoldenFile('files/home_with_statistics.png'),
    );
  });

  testWidgets('matches initial Game', (tester) async {
    await pumpGolden(
      tester,
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _MemorySettingsRepository(),
          ),
          gameSoundPlayerProvider.overrideWithValue(_SilentGameSoundPlayer()),
        ],
        child: goldenApp(home: const GameScreen()),
      ),
    );

    await expectLater(
      find.byKey(goldenSurfaceKey),
      matchesGoldenFile('files/game_initial.png'),
    );
  });

  testWidgets('matches populated History', (tester) async {
    final repository = _MemoryGameRecordRepository([
      _record(
        id: 'recent-win',
        outcome: GameOutcome.playerOneWin,
        difficulty: GameDifficulty.medium,
        skin: GameSymbolSkin.tennis,
      ),
      _record(
        id: 'loss',
        outcome: GameOutcome.playerTwoWin,
        difficulty: GameDifficulty.hard,
        skin: GameSymbolSkin.football,
      ),
      _record(
        id: 'draw',
        outcome: GameOutcome.draw,
        difficulty: GameDifficulty.easy,
        skin: GameSymbolSkin.geometric,
      ),
    ]);

    await pumpGolden(
      tester,
      ProviderScope(
        overrides: [
          gameRecordsProvider.overrideWith((ref) => repository.getAll()),
          gameRecordRepositoryProvider.overrideWithValue(repository),
        ],
        child: goldenApp(home: const HistoryScreen()),
      ),
    );

    await expectLater(
      find.byKey(goldenSurfaceKey),
      matchesGoldenFile('files/history_populated.png'),
    );
  });

  testWidgets('matches Settings controls', (tester) async {
    await pumpGolden(
      tester,
      goldenApp(
        home: Scaffold(
          body: SettingsSheet(
            settings: AppSettings.defaults.copyWith(
              theme: AppThemePreference.dark,
              difficulty: GameDifficulty.medium,
              skin: GameSymbolSkin.football,
            ),
            onThemeChanged: (_) async {},
            onDifficultyChanged: (_) async {},
            onSkinChanged: (_) async {},
            onSoundEnabledChanged: (_) async {},
            onClose: () {},
          ),
        ),
      ),
    );

    await expectLater(
      find.byKey(goldenSurfaceKey),
      matchesGoldenFile('files/settings_controls.png'),
    );
  });

  testWidgets('matches every symbol skin and mark', (tester) async {
    await pumpGolden(
      tester,
      goldenApp(
        home: Scaffold(
          body: SafeArea(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              childAspectRatio: 1.35,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (final skin in GameSymbolSkin.values)
                  _SymbolSkinSample(skin: skin),
              ],
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byKey(goldenSurfaceKey),
      matchesGoldenFile('files/symbol_skin_matrix.png'),
    );
  });
}

class _SymbolSkinSample extends StatelessWidget {
  const _SymbolSkinSample({required this.skin});

  final GameSymbolSkin skin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(skin.name.toUpperCase()),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GameSymbol(mark: GameSymbolMark.x, skin: skin, size: 54),
              GameSymbol(mark: GameSymbolMark.o, skin: skin, size: 54),
            ],
          ),
        ],
      ),
    );
  }
}

final class _MemorySettingsRepository implements SettingsRepository {
  AppSettings value = AppSettings.defaults;

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<void> save(AppSettings settings) async => value = settings;
}

final class _SilentGameSoundPlayer implements GameSoundPlayer {
  @override
  Future<void> prepare() async {}

  @override
  Future<void> play(GameSoundCue cue) async {}
}

final class _MemoryGameRecordRepository implements GameRecordRepository {
  _MemoryGameRecordRepository(Iterable<GameRecord> records)
    : _records = [...records];

  final List<GameRecord> _records;

  @override
  Future<void> clear() async => _records.clear();

  @override
  Future<void> delete(String id) async {
    _records.removeWhere((record) => record.id == id);
  }

  @override
  Future<List<GameRecord>> getAll() async => List.unmodifiable(_records);

  @override
  Future<void> save(GameRecord record) async => _records.add(record);
}

GameRecord _record({
  required String id,
  required GameOutcome outcome,
  GameDifficulty difficulty = GameDifficulty.hard,
  GameSymbolSkin skin = GameSymbolSkin.classic,
}) {
  return GameRecord(
    id: id,
    playerOneName: 'You',
    playerTwoName: 'CPU',
    outcome: outcome,
    moveCount: 7,
    completedAt: DateTime.now().subtract(const Duration(hours: 2)),
    difficulty: difficulty,
    skin: skin,
  );
}
