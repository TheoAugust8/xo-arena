import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final sourceFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !file.path.endsWith('.g.dart'))
      .where((file) => !file.path.endsWith('.freezed.dart'))
      .toList();

  test('domain stays independent from frameworks', () {
    const forbiddenPackages = [
      'package:flutter/',
      'package:flutter_riverpod/',
      'package:go_router/',
      'package:riverpod_annotation/',
      'package:shared_preferences/',
      'package:audioplayers/',
      'package:json_annotation/',
    ];

    final violations = _violations(
      sourceFiles.where((file) => file.path.contains('/domain/')),
      (importPath, _) => forbiddenPackages.any(importPath.startsWith),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation never imports data implementations', () {
    final violations = _violations(
      sourceFiles.where((file) => file.path.contains('/presentation/')),
      (importPath, _) => importPath.contains('/data/'),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('data never imports presentation', () {
    final violations = _violations(
      sourceFiles.where((file) => file.path.contains('/data/')),
      (importPath, _) => importPath.contains('/presentation/'),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('features and shared modules never import app', () {
    final violations = _violations(
      sourceFiles.where(
        (file) =>
            file.path.contains('/features/') || file.path.contains('/shared/'),
      ),
      (importPath, _) => importPath.startsWith('package:xo_arena/app/'),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('core stays independent from product modules', () {
    final violations = _violations(
      sourceFiles.where((file) => file.path.contains('/core/')),
      (importPath, _) =>
          importPath.startsWith('package:xo_arena/app/') ||
          importPath.startsWith('package:xo_arena/features/') ||
          importPath.startsWith('package:xo_arena/shared/'),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('features never import another feature', () {
    final violations = _violations(
      sourceFiles.where((file) => file.path.contains('/features/')),
      _isCrossFeatureDependency,
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('use cases live inside domain layer', () {
    final violations = sourceFiles
        .map((file) => file.path)
        .where((path) => path.contains('/usecases/'))
        .where((path) => !path.contains('/domain/usecases/'))
        .toList();

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('domain sources live inside responsibility folders', () {
    final violations = sourceFiles
        .map((file) => file.path)
        .where((path) => RegExp(r'/domain/[^/]+\.dart$').hasMatch(path))
        .toList();

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('game domain stays independent from application settings', () {
    final violations = _violations(
      sourceFiles.where((file) => file.path.contains('/features/game/domain/')),
      (importPath, _) =>
          importPath.startsWith('package:xo_arena/shared/settings/'),
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('data sources live inside responsibility folders', () {
    final violations = sourceFiles
        .map((file) => file.path)
        .where((path) => RegExp(r'/data/[^/]+\.dart$').hasMatch(path))
        .toList();

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('architecture scanner covers every Dart library directive', () {
    const source = """
import "package:one/import.dart" show Imported;
export 'package:two/export.dart' hide Exported;
import 'fallback.dart'
  if (dart.library.io) 'io.dart';
part 'parts/local.dart';
part of 'package:three/library.dart';
""";

    expect(_directivePaths(source), [
      'package:one/import.dart',
      'package:two/export.dart',
      'fallback.dart',
      'io.dart',
      'parts/local.dart',
      'package:three/library.dart',
    ]);
  });

  test('cross feature rule covers every feature layer', () {
    for (final sourcePath in [
      'lib/features/game/domain/entities/game.dart',
      'lib/features/game/data/models/game_dto.dart',
      'lib/features/game/presentation/game_screen.dart',
    ]) {
      expect(
        _isCrossFeatureDependency(
          'package:xo_arena/features/history/domain/usecases/clear_history.dart',
          sourcePath,
        ),
        isTrue,
      );
    }

    expect(
      _isCrossFeatureDependency(
        'package:xo_arena/features/game/domain/entities/game.dart',
        'lib/features/game/presentation/game_screen.dart',
      ),
      isFalse,
    );
    expect(
      _isCrossFeatureDependency(
        'package:xo_arena/shared/game_records/domain/entities/game_record.dart',
        'lib/features/game/domain/usecases/complete_game.dart',
      ),
      isFalse,
    );
  });
}

List<String> _violations(
  Iterable<File> files,
  bool Function(String importPath, String sourcePath) isForbidden,
) {
  final violations = <String>[];
  for (final file in files) {
    final source = file.readAsStringSync();
    for (final directivePath in _directivePaths(source)) {
      if (isForbidden(directivePath, file.path)) {
        violations.add('${file.path}: $directivePath');
      }
    }
  }
  return violations;
}

Iterable<String> _directivePaths(String source) sync* {
  final directivePattern = RegExp(
    r'^(?:import|export|part(?:\s+of)?)\s+([^;]+);',
    multiLine: true,
  );
  final uriPattern = RegExp(r'''['"]([^'"]+)['"]''');
  for (final directive in directivePattern.allMatches(source)) {
    for (final uri in uriPattern.allMatches(directive.group(1)!)) {
      yield uri.group(1)!;
    }
  }
}

String? _featureName(String path) {
  return RegExp(r'/features/([^/]+)/').firstMatch(path)?.group(1);
}

bool _isCrossFeatureDependency(String importPath, String sourcePath) {
  final sourceFeature = _featureName(sourcePath);
  final importedFeature = RegExp(
    r'^package:xo_arena/features/([^/]+)/',
  ).firstMatch(importPath)?.group(1);
  return sourceFeature != null &&
      importedFeature != null &&
      importedFeature != sourceFeature;
}
