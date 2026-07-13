import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/core/design_system/app_theme.dart';
import 'package:xo_arena/core/design_system/app_theme_tokens.dart';
import 'package:xo_arena/core/design_system/components/app_button.dart';
import 'package:xo_arena/features/game/domain/game_round.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_cell.dart';
import 'package:xo_arena/features/game/presentation/models/game_symbol_skin.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_score.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_settings_sheet.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_status_badge.dart';
import 'package:xo_arena/features/game/presentation/widgets/game_symbol.dart';

void main() {
  Widget themed(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.dark,
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('renders every cell variant', (tester) async {
    for (final variant in GameCellVariant.values) {
      await tester.pumpWidget(
        themed(GameCell(variant: variant, onPressed: () {})),
      );
      expect(find.byType(GameCell), findsOneWidget);
    }

    await tester.pumpWidget(
      themed(const GameCell(variant: GameCellVariant.playerX)),
    );
    expect(find.text('X'), findsOneWidget);

    await tester.pumpWidget(
      themed(const GameCell(variant: GameCellVariant.cpuO)),
    );
    expect(find.text('O'), findsOneWidget);

    await tester.pumpWidget(
      themed(const GameCell(variant: GameCellVariant.winning)),
    );
    final materials = tester.widgetList<Material>(find.byType(Material));
    expect(
      materials.map((material) => material.color),
      contains(AppThemeTokens.dark.winBackground),
    );
  });

  testWidgets('renders status badge labels', (tester) async {
    for (final variant in GameStatusVariant.values) {
      await tester.pumpWidget(themed(GameStatusBadge(variant: variant)));
      expect(find.text(variant.label), findsOneWidget);
    }

    await tester.pumpWidget(
      themed(const GameStatusBadge(variant: GameStatusVariant.player)),
    );
    expect(find.byType(AnimatedContainer), findsOneWidget);
  });

  testWidgets('renders button variants and disabled state', (tester) async {
    await tester.pumpWidget(
      themed(
        Column(
          children: [
            AppButton.primary(label: 'NEW GAME', onPressed: () {}),
            AppButton.secondary(label: 'NEW GAME', onPressed: () {}),
            const AppButton.primary(label: 'NEW GAME'),
          ],
        ),
      ),
    );

    expect(find.byType(AppButton), findsNWidgets(3));
    expect(find.text('NEW GAME'), findsNWidgets(3));
  });

  testWidgets('renders score component', (tester) async {
    await tester.pumpWidget(
      themed(const GameScore(playerScore: 3, cpuScore: 1)),
    );

    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('CPU'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('VS'), findsOneWidget);
  });

  testWidgets('renders settings variants', (tester) async {
    await tester.pumpWidget(
      themed(
        GameSettingsSheet(
          themeMode: ThemeMode.dark,
          difficulty: GameDifficulty.medium,
          skin: GameSymbolSkin.classic,
          onThemeModeChanged: (_) {},
          onDifficultyChanged: (_) {},
          onSkinChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Difficulty'), findsOneWidget);
    expect(find.text('Skin'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(
      find.text('CPU makes occasional mistakes. A balanced challenge.'),
      findsOneWidget,
    );
    expect(find.byType(GameSymbol), findsNWidgets(8));
  });

  testWidgets('uses distinct icons for power and nature skins', (tester) async {
    await tester.pumpWidget(
      themed(
        const Row(
          children: [
            GameSymbol(mark: GameSymbolMark.x, skin: GameSymbolSkin.power),
            GameSymbol(mark: GameSymbolMark.o, skin: GameSymbolSkin.power),
            GameSymbol(mark: GameSymbolMark.x, skin: GameSymbolSkin.nature),
            GameSymbol(mark: GameSymbolMark.o, skin: GameSymbolSkin.nature),
          ],
        ),
      ),
    );

    expect(find.byIcon(Icons.bolt), findsOneWidget);
    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
  });
}
