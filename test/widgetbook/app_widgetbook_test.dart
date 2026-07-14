// The catalog entry point lives in tool/, outside the package library.
// ignore_for_file: always_use_package_imports

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook/widgetbook.dart';
import '../../tool/widgetbook/app_widgetbook.dart';

void main() {
  test('catalogs foundations and component states', () {
    final directories = appWidgetbookDirectories;
    final foundations = directories
        .whereType<WidgetbookFolder>()
        .firstWhere((folder) => folder.name == 'Foundations')
        .children!
        .whereType<WidgetbookComponent>();
    final components = directories
        .whereType<WidgetbookFolder>()
        .firstWhere((folder) => folder.name == 'Components')
        .children!
        .whereType<WidgetbookComponent>();
    final buttons = components.firstWhere(
      (component) => component.name == 'Buttons',
    );
    final themeTokens = foundations.firstWhere(
      (component) => component.name == 'Theme tokens',
    );
    final settings = components.firstWhere(
      (component) => component.name == 'Settings',
    );

    expect(directories.map((directory) => directory.name), [
      'Foundations',
      'Components',
    ]);
    expect(buttons.useCases.map((useCase) => useCase.name), [
      'Primary',
      'Secondary',
      'Disabled',
    ]);
    expect(themeTokens.useCases.map((useCase) => useCase.name), [
      'Dark',
      'Light',
    ]);
    expect(
      foundations.map((component) => component.name),
      containsAll(['Typography', 'Spacing', 'Radius', 'Shadows']),
    );
    expect(
      components.map((component) => component.name),
      containsAll([
        'Buttons',
        'Cells',
        'Status badges',
        'Score',
        'Symbol skins',
        'Settings',
      ]),
    );
    expect(
      settings.useCases.map((useCase) => useCase.name),
      containsAll([
        'Dark hard classic',
        'Light easy geometric',
        'Dark medium tennis',
        'Light hard football',
      ]),
    );
  });

  testWidgets('renders the design system catalog', (tester) async {
    await tester.pumpWidget(const AppWidgetbook());

    expect(find.byType(Widgetbook), findsOneWidget);
  });

  testWidgets('shows every theme token in a mobile viewport without overflow', (
    tester,
  ) async {
    final useCase = appWidgetbookDirectories
        .whereType<WidgetbookFolder>()
        .firstWhere((folder) => folder.name == 'Foundations')
        .children!
        .whereType<WidgetbookComponent>()
        .firstWhere((component) => component.name == 'Theme tokens')
        .useCases
        .first;

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    final preview = useCase.builder(tester.element(find.byType(SizedBox)));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SizedBox(width: 390, height: 656, child: preview)),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
