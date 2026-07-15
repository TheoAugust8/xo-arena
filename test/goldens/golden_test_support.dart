import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xo_arena/core/design_system/app_theme.dart';
import 'package:xo_arena/l10n/l10n.dart';

const goldenSurfaceKey = ValueKey('golden_surface');
const goldenSurfaceSize = Size(390, 844);

Uri _platformGoldenFile(Uri golden) {
  final platformDirectory = switch (Platform.operatingSystem) {
    'linux' => 'linux',
    'macos' => 'macos',
    final operatingSystem => throw UnsupportedError(
      'Golden baselines are unavailable for $operatingSystem.',
    ),
  };
  final segments = golden.pathSegments;
  return golden.replace(
    path: [
      ...segments.take(segments.length - 1),
      platformDirectory,
      segments.last,
    ].join('/'),
  );
}

Future<void> loadGoldenFonts() async {
  final inter = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
  final barlowCondensed = FontLoader('Barlow Condensed')
    ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-Black.ttf'));
  final materialIcons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await Future.wait([
    inter.load(),
    barlowCondensed.load(),
    materialIcons.load(),
  ]);
}

void configureGoldenComparator() {
  final previousComparator = goldenFileComparator;
  goldenFileComparator = TolerantGoldenFileComparator(
    Uri.parse('test/goldens/xo_arena_golden_test.dart'),
    precisionTolerance: 0.005,
  );
  addTearDown(() => goldenFileComparator = previousComparator);
}

Future<void> pumpGolden(WidgetTester tester, Widget child) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = goldenSurfaceSize;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  await tester.pumpWidget(child);
  await tester.pumpAndSettle();
}

Widget goldenApp({required Widget home}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark.copyWith(platform: TargetPlatform.android),
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: RepaintBoundary(key: goldenSurfaceKey, child: child),
      );
    },
    home: home,
  );
}

final class TolerantGoldenFileComparator extends LocalFileComparator {
  TolerantGoldenFileComparator(
    super.testFile, {
    required double precisionTolerance,
  }) : assert(
         precisionTolerance >= 0 && precisionTolerance <= 1,
         'precisionTolerance must be between 0 and 1',
       ),
       _precisionTolerance = precisionTolerance;

  final double _precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final platformGolden = _platformGoldenFile(golden);
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(platformGolden),
    );
    final passed = result.passed || result.diffPercent <= _precisionTolerance;
    if (passed) {
      result.dispose();
      return true;
    }

    final error = await generateFailureOutput(result, platformGolden, basedir);
    result.dispose();
    throw FlutterError(error);
  }

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) {
    return super.update(_platformGoldenFile(golden), imageBytes);
  }
}
